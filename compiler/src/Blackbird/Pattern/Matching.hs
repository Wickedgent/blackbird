{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE PatternGuards #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ParallelListComp #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
--------------------------------------------------------------------
-- |
-- Copyright :  (c) Dan Doel and Edward Kmett 2013-2014
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable
--
--------------------------------------------------------------------
module Blackbird.Pattern.Matching
  (
  -- * Matching
    Matching(..)
  , HasMatching(..)
  -- * Compilation
  , compile
  , compileBinding
  , compileLambda
  , compileCase
  -- * builtin lambda using patterns
  , plam
  ) where

import Prelude hiding (all)

import Bound
import Bound.Scope
import Control.Comonad
import Control.Lens hiding (matching)
import Control.Monad.Trans (lift)
import Data.Either (partitionEithers)
import Data.Foldable hiding (concatMap)
import Data.HashMap.Lazy (HashMap)
import qualified Data.HashMap.Lazy as HM
import qualified Data.Map as M
import Data.List (transpose, genericLength)
import Data.Maybe
import Data.Ord
import Data.Set (Set)
import Data.Set.Lens
import Data.Text as SText (pack)
import Data.Traversable
import Data.Word
import Blackbird.Builtin.Global
import Blackbird.Builtin.Pattern
import Blackbird.Pattern.Env
import Blackbird.Pattern.Matrix
import Blackbird.Syntax.Convention
import Blackbird.Syntax.Core as Core
import Blackbird.Syntax.Pattern
import Blackbird.Syntax.Scope
import Blackbird.Syntax.Term

-- | Additional information needed for pattern compilation that does not
-- really belong in the pattern matrix.
--
-- The 'pathMap' stores information for resolving previous levels of the
-- pattern to appropriate cores for the current context.
--
-- 'colCores' contains core terms that refer to each of the columns of the
-- matrix in the current context.
--
-- 'colPaths' contains the paths into the original pattern that correspond to
-- each of the current columns.
data Matching c a = Matching
  { _pathMap  :: HashMap PatternPath (c a)
  , _colCores :: [c a]
  , _colPaths :: [PatternPaths]
  } deriving (Functor, Foldable, Traversable)

makeClassy ''Matching

-- | @'remove' i@ removes the /i/th column of the 'Matching'. This is for use
-- when compiling the default case for a column, and thus the resulting
-- 'Matching' is lifted to be used in such a context.
remove :: Applicative c => Int -> Matching c a -> Matching c (Var () (c a))
remove i (Matching m ccs cps) = case (splitAt i ccs, splitAt i cps) of
  ((cl, _:cr), (pl, p:pr)) ->
    Matching (HM.insert (leafPP p) (pure $ B ()) $ fmap (pure . F) m)
          (map (pure . F) $ cl ++ cr)
          (pl ++ pr)
  _ -> error "PANIC: remove: bad column reference"

-- | @'expand' i n@ expands the /i/th column of a pattern into /n/ columns. This
-- is for use when compiling a constructor case of a pattern, and thus the
-- 'Matching' returned is prepared to be used in such a case.
expand :: Applicative c
       => Int -> Word64 -> Matching c a -> Matching c (Var Word64 (c a))
expand i n (Matching m ccs cps) = case (splitAt i ccs, splitAt i cps) of
  ((cl, _:cr), (pl, p:pr)) ->
    Matching (HM.insert (leafPP p) (pure $ B 0) $ fmap (pure . F) m)
          (map (pure . F) cl ++ map (pure . B) [1..n] ++ map (pure . F) cr)
          (pl ++ map (\j -> p <> fieldPP j) [0..n - 1] ++ pr)
  _ -> error "PANIC: expand: bad column reference"

instantiation :: Matching c a -> PatternPath -> c a
instantiation (Matching pm cc cp) pp = fromMaybe
  (error $ "PANIC: instantiation: unknown pattern reference: " ++ show pp) (HM.lookup pp pm')
 where
 pm' = HM.union pm . HM.fromList $ zip (map leafPP cp) cc

-- | A helper function to make a more deeply nested core.
promote :: (Functor f, Functor g, Applicative c) => f (g a) -> f (g (Var b (c a)))
promote = fmap . fmap $ F . pure

-- | This lifts a Matching to work under one additional scope. This is
-- necessary when we compile a guard, which eliminates a row, but leaves
-- all columns in place.
bumpM :: Applicative c => Matching c a -> Matching c (Var b (c a))
bumpM (Matching m cs ps) = Matching (promote m) (promote cs) ps

hbumpM :: Monad c => Matching c a -> Matching (Scope b c) a
hbumpM (Matching m cs ps) = Matching (lift <$> m) (lift <$> cs) ps

bumpPM :: Applicative c => PatternMatrix t c a -> PatternMatrix t c (Var b (c a))
bumpPM (PatternMatrix ps bs) = PatternMatrix ps (promote bs)

hbumpPM :: Monad c => PatternMatrix t c a -> PatternMatrix t (Scope b c) a
hbumpPM (PatternMatrix ps bs) = PatternMatrix ps (hoistClaused lift <$> bs)

-- | Computes the set of heads of the given patterns.
patternHeads :: [Pattern t] -> Set PatternHead
patternHeads = setOf (traverse.patternHead)

-- | Uses a heuristic to select a column from a pattern matrix.
--
-- The current heuristic selects a column with the longest initial segment
-- of patterns that force evaluation.
selectCol :: [[Pattern t]] -> Maybe Int
selectCol = fmap fst
          . maximumByOf folded (comparing snd)
          . zip [0..]
          . map (length . takeWhile forces)

compileClaused :: (MonadPattern m, AsConvention cc, Cored cc c)
               => Matching c a
               -> PatternMatrix t c a
               -> Claused c a
               -> m (c a)
compileClaused m pm (Raw gbs) = compileGuards m pm gbs
compileClaused m pm (Localized ws gbs) =
  letrec (inst <$> ws) <$> compileGuards m' pm' gbs
 where
 m' = hbumpM m
 pm' = hbumpPM pm
 inst = instantiate (instantiation m')

compileGuards :: (MonadPattern m, AsConvention cc, Cored cc c)
              => Matching c a
              -> PatternMatrix t c a
              -> Guarded (Scope PatternPath c a)
              -> m (c a)
-- In the unguarded case, we can terminate immediately, because all patterns
-- leading up to here matched trivially.
compileGuards m _  (Unguarded body) = pure $ instantiate (instantiation m) body
compileGuards m pm (Guarded bods) = compileManyGuards m pm bods

compileManyGuards :: (MonadPattern m, AsConvention cc, Cored cc c)
                  => Matching c a
                  -> PatternMatrix t c a
                  -> [Pair (Scope PatternPath c a)]
                  -> m (c a)
compileManyGuards m pm [] = compile m pm
-- TODO: check for a trivial guard here
compileManyGuards m pm (Pair g b:gbs) =
  compileManyGuards
    (bumpM m)
    (bumpPM pm)
    (over (traverse.traverse) (fmap $ F . pure) gbs) <&> \f ->
  case_ (inst g) ?? Nothing $
    M.fromList
      [ (1, Match [] trueg  $ Scope . fmap (F . pure) $ inst b)
      , (0, Match [] falseg $ Scope f)
      ]
 where inst = instantiate (instantiation m)


-- | Compiles a pattern matrix together with a corresponding set of core
-- branches to a final Core value, which will be the decision tree version
-- of the pattern matrix.
compile :: (AsConvention cc, MonadPattern m, Cored cc c)
        => Matching c a -> PatternMatrix t c a -> m (c a)
compile _  (PatternMatrix _  [])  = pure . hardCore $ Error (SText.pack "non-exhaustive pattern match.")
compile m pm@(PatternMatrix ps (b:bs))
  | all (irrefutable . head) ps =
     compileClaused m (PatternMatrix (drop 1 <$> ps) bs) b
  | Just i <- selectCol ps = let
      col = ps !! i
      heads = patternHeads col
      dm = defaultOn i pm
    in do sig <- isSignature heads
          sms <- for (toListOf folded heads) $ \h -> case h of
            LitH l -> do
                c <- compile (expand i 1 m) (splitOn i h pm)
                return $ Left (l, c)
            _ -> do
                (cc, tg) <- constructorTag h
                c <- compile (expand i (genericLength cc) m) (splitOn i h pm)
                return $ Right (tg,
                  Match (review _Convention <$> cc) (constructorGlobal h) $ Scope c)
          case partitionEithers sms of
            ([],xs) -> case_ ((m^.colCores) !! i) (M.fromList xs) <$>
              if sig then pure Nothing
                     else Just . Scope <$> compile (remove i m) dm
            (_s,[]) -> undefined --
              {-
              do
               dflt <- if sig then pure Nothing
                              else Just . set (mapped._B) 0 <$> compile (remove i m) dm
               let (cc,nt) = case fst (head xs) of String{} -> (Match [N] stringg, True); _ -> (Match [U] literalg, False)
               -- return $ ((lambda [C] C (Scope $ caseLit cc (core $ unbox cc $ pure $ B 0) (M.fromList xs) dflt)) ## ((m^.colCores) !! i))
               return $ case_ ((m^.colCores)!!i) (M.singleton 0 $ cc $ Scope $ caseLit nt (pure $ B 1) (M.fromList xs) dflt) Nothing
              -}
            _ -> error "PANIC: pattern compile: mixed literal and constructor patterns"
  | otherwise = error "PANIC: pattern compile: No column selected."

-- wrong, placeholder
--unbox :: Bool -> c a -> c a
-- unbox _ = id

bodyVar :: BodyBound -> Var (Var PatternPath Word64) Word64
bodyVar (BodyDecl w) = F w
bodyVar (BodyPat p) = B (B p)
bodyVar (BodyWhere w) = B (F w)

bodyVar_ :: BodyBound -> Var PatternPath Word64
bodyVar_ (BodyDecl w) = F w
bodyVar_ (BodyPat p) = B p
bodyVar_ (BodyWhere _) = error "panic: reference to non-existent where clause detected"

whereVar :: WhereBound -> Var PatternPath Word64
whereVar (WhereDecl w) = F w
whereVar (WherePat p) = B p

compileBinding
  :: forall m cc t c a. (MonadPattern m, AsConvention cc, Cored cc c)
  => [cc] -> [[Pattern t]] -> [Guarded (Scope BodyBound c a)] -> [[Scope (Var WhereBound Word64) c a]] -> m (Scope Word64 c a)
compileBinding ccvs ps gds ws = lambda ccvs <$> compile m pm where
  clause g [] = Raw (hoistScope lift . splitScope . mapBound bodyVar_ <$> g)
  clause g w = Localized (splitScope . mapBound whereVar . hoistScope lift . splitScope <$> w)
                         (splitScope . hoistScope lift . splitScope . mapBound bodyVar <$> g)
  pm :: PatternMatrix t (Scope Word64 (Scope Word64 c)) a
  pm = PatternMatrix (transpose ps) (zipWith clause gds ws)
  pps = zipWith (const . argPP) [0..] (head ps)
  cs :: [Scope Word64 (Scope Word64 c) a]
  cs = zipWith (const . Scope . pure . B) [(0 :: Word64)..] (head ps)
  m = Matching (HM.fromList $ zipWith ((,) . leafPP) pps cs) cs pps

compileLambda
  :: forall m cc t c a. (MonadPattern m, AsConvention cc, Cored cc c)
  => [Pattern t] -> Scope PatternPath c a -> m (Scope Word64 c a)
compileLambda ps body = compile m pm where
 pm :: PatternMatrix t (Scope Word64 c) a
 pm = PatternMatrix (map return ps) [Raw . Unguarded $ hoistScope lift body]
 pps = zipWith (const . argPP) [0..] ps
 cs :: [Scope Word64 c a]
 cs = zipWith (const . Scope . pure . B) [0..] ps
 m = Matching (HM.fromList $ zipWith ((,) . leafPP) pps cs) cs pps

compileCase
  :: (MonadPattern m, AsConvention cc, Cored cc c)
  => [Pattern t] -> c a -> [Guarded (Scope PatternPath c a)] -> m (c a)
compileCase ps disc bs = compile m pm where
 pm = PatternMatrix [ps] (Raw <$> bs)
 m = Matching HM.empty [disc] [mempty]

plam :: forall m cc t v. (AsConvention cc, Eq v, MonadPattern m)
     => [P t v] -> Core cc v -> m (Core cc v)
plam ps body = Core.Lam (_Convention # C <$ ps) . Scope <$> compile ci pm
 where
 n = fromIntegral $ length ps :: Word64
 assocs = concatMap (\(i,Binder vs p) -> zip vs . fmap (ArgPP i) $ paths p) (zip [0..] ps)
 pm :: PatternMatrix t (Core cc) (Var Word64 (Core cc v))
 pm = PatternMatrix (pure . extract <$> ps)
              [Raw . Unguarded $ F . pure <$> abstract (`lookup` assocs) body]
 ci :: Matching (Core cc) (Var Word64 (Core cc v))
 ci = Matching HM.empty (pure . B <$> [0..n-1]) (argPP <$> [0..n-1])
