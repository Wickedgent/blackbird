{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE PatternGuards #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ScopedTypeVariables #-}

--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett and Dan Doel 2014
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable
--------------------------------------------------------------------

module Blackbird.Core.Optimizer
  ( optimize
  , rewriteCore
  , rewriteCoreDown
  ) where

import Bound
import Bound.Var
import Bound.Scope
import Control.Lens
import Control.Monad.Writer
import Data.List (genericLength, genericSplitAt, genericIndex)
import Data.Word
import Blackbird.Syntax
import Blackbird.Syntax.Convention
import Blackbird.Syntax.Core
import Blackbird.Syntax.Scope
import Blackbird.Unification.Sharing

-- | Optimize core expressions by alternating between the different optimization passes several times.
optimize :: Core Convention c -> Core Convention c
optimize c = runIdentity . runSharing c $ optimize' 10 c

optimize' :: forall m c. MonadWriter Any m
          => Int -> Core Convention c -> m (Core Convention c)
optimize' 0 c = return c
optimize' n c = do (c', Any b) <- listen $ suite c
                   if b then optimize' (n-1) c' else return c
 where
 suite :: Core Convention c -> m (Core Convention c)
 suite = rewriteCoreDown lamlam
     >=> rewriteCore betaVar
     >=> rewriteCoreDown specCase
     >=> rewriteCore etaDict

rewriteCoreDown :: forall m c cc. MonadWriter Any m
                => (forall d. Core cc d -> m (Core cc d)) -> Core cc c -> m (Core cc c)
rewriteCoreDown opt = go
 where
 go :: forall e. Core cc e -> m (Core cc e)
 go c = sharing c (opt c) >>= \ xs -> case xs of
   l@(Lam cc e)         -> sharing l $ Lam cc <$> goS e
   d@(Data cc n g l)    -> sharing d $ Data cc n g <$> traverse go l
   d@(Prim cc r g l)    -> sharing d $ Prim cc r g <$> traverse go l
   a@(App cc f x)       -> sharing a $ App cc <$> go f <*> go x
   l@(Let d b)          -> sharing l $ Let <$> sharing d (traverse goS d) <*> goS b
   s@(Case e b d)       -> sharing s $ Case <$> go e <*> sharing b ((traverse.matchBody) goS b) <*> sharing d (traverse goS d)
   d@(Dict su sl)       -> sharing d $ Dict <$> sharing su (traverse go su) <*> sharing sl (traverse goS sl)
   x@HardCore{}         -> return x
   x@Var{}              -> return x
 goS :: forall b e. Scope b (Core cc) e -> m (Scope b (Core cc) e)
 goS s = sharing s . inScope go $ s

rewriteCore :: forall m c cc. MonadWriter Any m
            => (forall d. Core cc d -> m (Core cc d)) -> Core cc c -> m (Core cc c)
rewriteCore opt = go
 where
 go :: forall e. Core cc e -> m (Core cc e)
 go c = sharing c $ opt =<< case c of
   l@(Lam cc e)         -> sharing l $ Lam cc <$> goS e
   d@(Data cc n g l)    -> sharing d $ Data cc n g <$> traverse go l
   d@(Prim cc r g l)    -> sharing d $ Prim cc r g <$> traverse go l
   a@(App cc f x)       -> sharing a $ App cc <$> go f <*> go x
   l@(Let d b)          -> sharing l $ Let <$> sharing d (traverse goS d) <*> goS b
   s@(Case e b d)       -> sharing s $ Case <$> go e <*> sharing b ((traverse.matchBody) goS b) <*> sharing d (traverse goS d)
   d@(Dict su sl)       -> sharing d $ Dict <$> sharing su (traverse go su) <*> sharing sl (traverse goS sl)
   x@HardCore{}         -> return x
   x@Var{}              -> return x
 goS :: forall b e. Scope b (Core cc) e -> m (Scope b (Core cc) e)
 goS s = sharing s . inScope go $ s

-- | Turns @\{x..} -> \{y..} -> ...@ into @\{x.. y..} -> ...@ for all lambda variants
lamlam :: forall c cc m. MonadWriter Any m => Core cc c -> m (Core cc c)
lamlam (Lam cc0 e0) = slurp False cc0 (fromScope e0)
 where
 slurp :: forall e. Bool -> [cc] -> Core cc (Var Word64 e) -> m (Core cc e)
 slurp _ m (Lam n b) | j <- fromIntegral $ length m = slurp True (m ++ n) (instantiate (\i -> pure $ B $ j + i) b)
 slurp b m c = Lam m (toScope c) <$ tell (Any b)
lamlam c = return c

-- | 'Lam D' is strict, so η-reduction for it is sound. η-reduce.
--
-- Todo: generalize this to larger lambdas and also extend it to cover other strict lambdas like U and N
etaDict :: forall c m. MonadWriter Any m => Core Convention c -> m (Core Convention c)
etaDict c@(Lam [D] (Scope (App D f (Var (B 0))))) = case sequenceA f of
  B _ -> return c
  F g -> join g <$ tell (Any True)
etaDict c = return c

-- | β-reduces redexes like @(\x.. -> e) v..@ where @v..@ is all variables for all calling conventions
betaVar :: forall c m. MonadWriter Any m => Core Convention c -> m (Core Convention c)
betaVar = collapse []
 where
 collapse stk (App C f x)
   | has _Var x || has _Slot x || has _Super x || has _Lit x = collapse (x:stk) f
 collapse stk (Lam cc body@(Scope body'))
   | len < n = do
     tell (Any True)
     let replace i
           | i < len   = F $ stk `genericIndex` i
           | otherwise = B $ i - len
     return $ Lam (drop (fromIntegral len) cc) $ Scope $ fmap (unvar replace F) body'
   | (args, stk') <- genericSplitAt n stk = do
     tell (Any True)
     collapse stk' $ instantiate (genericIndex args) body
   where
     len :: Word64
     len = genericLength stk
     n :: Word64
     n   = genericLength cc
 collapse stk c = return $ apps c stk

-- | Specializes a case expression to a known constructor.
--
-- TODO: switch to
--
-- (\\ a b c -> let x = Foo a b c in body) arg1 .. argN
--
-- and rely on beta reduction and other checks for work-safe application reduction
--
-- This has the benefit that it works for all calling conventions
specCase :: forall m c. MonadWriter Any m => Core Convention c -> m (Core Convention c)
specCase c@(Case dat@(Data cc tg g as) bs d)
  -- TODO: Use a LamHash around this for all the unboxed arguments, and AppHash each to an argument.
  | any (/=C) cc = pure c -- until we change this to use Lam as described above
  | Just (Match _cc _g body) <- bs ^. at tg =
    Let ((Scope . Data cc tg g $ pure . B <$> [1..fromIntegral arity]) : map lift as)
        body
      <$ tell (Any True)
  | Just e <- d = Let [lift dat] (mapBound (const 0) e) <$ tell (Any True)
  | otherwise = error "PANIC: non-exhaustive case with no default"
  where arity = length cc
specCase c = pure c
