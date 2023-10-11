{-# LANGUAGE CPP #-}
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
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE MultiWayIf #-}

--------------------------------------------------------------------
-- |
-- Copyright :  (c) Dan Doel and Edward Kmett 2013-2014
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable
--
--------------------------------------------------------------------
module Blackbird.Pattern.Matrix
  (
  -- * Pattern Matrix
    PatternMatrix(..)
  , HasPatternMatrix(..)
  , defaultOn
  , splitOn
  -- * Claused
  , Claused(..)
  , hoistClaused
  ) where

import Prelude hiding (all)

import Bound
import Bound.Scope
import Control.Lens
import Data.List (transpose)
import Data.Word
import Blackbird.Syntax.Pattern

#ifdef HLINT
{-# ANN module "hlint: ignore Eta reduce" #-}
#endif

-- * Claused

data Claused c a = Localized [Scope PatternPath (Scope Word64 c) a]
                             (Guarded (Scope PatternPath (Scope Word64 c) a))
                 | Raw (Guarded (Scope PatternPath c a))
  deriving (Eq, Show, Functor, Foldable, Traversable)

hoistClaused :: Functor c => (forall x. c x -> d x) -> Claused c a -> Claused d a
hoistClaused tr (Raw g) = Raw $ hoistScope tr <$> g
hoistClaused tr (Localized ds g) =
  Localized (hoistScope tr' <$> ds) (hoistScope tr' <$> g)
 where
 tr' = hoistScope tr

-- * Pattern Matrix

-- | Pattern matrices for compilation. The matrix is represented as a list
-- of columns. There is also an extra column representing the guards.
data PatternMatrix t c a = PatternMatrix
  { _cols     :: [[Pattern t]]
  , _bodies   :: [Claused c a]
  } deriving (Eq, Show, Functor, Foldable, Traversable)

makeClassy ''PatternMatrix

-- | A helper function to make a more deeply nested core.
promote :: (Functor f, Functor g, Applicative c) => f (g a) -> f (g (Var b (c a)))
promote = fmap . fmap $ F . pure

-- | Computes the matrix that should be used recursively when defaulting on
-- the specified column.
defaultOn :: Applicative c => Int -> PatternMatrix t c a -> PatternMatrix t c (Var () (c a))
defaultOn i (PatternMatrix ps cs)
  | (ls, c0:rs) <- splitAt i ps = let
      c = prune <$> c0
      select c' = map snd . filter (irrefutable.fst) $ zip c c'
    in PatternMatrix (map select $ ls ++ rs) (promote $ select cs)
  | otherwise = error "PANIC: defaultOn: bad column reference"

-- | Computes the matrix that should be used recursively when defaulting on
-- the specified column, with the given pattern head.
splitOn :: forall t c a. Applicative c
        => Int -> PatternHead -> PatternMatrix t c a -> PatternMatrix t c (Var Word64 (c a))
splitOn i hd (PatternMatrix ps cs)
  | (ls, c0:rs) <- splitAt i ps = let
      con pat = traverseHead hd pat
      c = prune <$> c0
      p (pat, _) = has con pat || irrefutable pat
      select c' = map snd . filter p $ zip c c'
      newcs :: [[Pattern t]]
      newcs = transpose $ c >>= \pat -> if
        | Just ps' <- preview con pat -> [ps']
        | irrefutable pat             -> [WildcardP <$ conventions hd]
        | otherwise                   -> []
    in PatternMatrix (map select ls ++ newcs ++ map select rs)
               (promote $ select cs)
  | otherwise = error "PANIC: splitOn: bad column reference"
