{-# LANGUAGE CPP #-}
{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: portable
--
-- This module provides extensions to the @bound@ package.
--------------------------------------------------------------------
module Blackbird.Syntax.Scope
  ( hoistScope
  , bitraverseScope
  , transverseScope
  , BoundBy(..)
  , instantiateVars
  -- , putVar , getVar , putScope, getScope
  , serializeScope3
  , deserializeScope3
  , mergeScope
  , splitScope
  , rebind
  , inScope
  , _Scope
  ) where

import Bound
import Bound.Scope
import Bound.Var
import Control.Lens
import Control.Monad (liftM)
import Control.Monad.Trans
import Data.Bytes.Serial
import Data.Bytes.Get
import Data.Bytes.Put

-- | Generalizes 'Bound' to permit binding by another type without taking it as a parameter.
class Monad m => BoundBy tm m | tm -> m where
  boundBy :: (a -> m b) -> tm a -> tm b

instance Monad m => BoundBy (Scope b m) m where
  boundBy = flip (>>>=)
  {-# INLINE boundBy #-}

serializeScope3 :: MonadPut m
                => (b -> m ()) -> (forall a. (a -> m ()) -> f a -> m ()) -> (v -> m ())
                -> Scope b f v -> m ()
serializeScope3 pb pf pv (Scope e) = pf (serializeWith2 pb (pf pv)) e

deserializeScope3 :: MonadGet m
                  => m b -> (forall a. m a -> m (f a)) -> m v
                  -> m (Scope b f v)
deserializeScope3 gb gf gv = Scope <$> gf (deserializeWith2 gb (gf gv))

mergeScope :: Monad c => Scope b1 (Scope b2 c) a -> Scope (Var b1 b2) c a
mergeScope = toScope . liftM go . fromScope . fromScope where
  go :: Var a1 (Var b a2) -> Var (Var b a1) a2
  go (B b2)     = B (F b2)
  go (F (B b1)) = B (B b1)
  go (F (F a))  = F a

splitScope :: Monad c
           => Scope (Var b1 b2) c a -> Scope b1 (Scope b2 c) a
-- c (Var (Var b1 b2) (c a))
-- Scope b2 c (Var b1 (Scope b2 c a))
splitScope (Scope e) = Scope . lift $ swizzle <$> e
 where
 swizzle :: Monad f => Var (Var b1 b2) (f a) -> Var b1 (Scope b2 f a)
 swizzle (B (B b1)) = B b1
 swizzle (B (F b2)) = F . Scope . pure . B $ b2
 swizzle (F a)      = F $ lift a

-- | Enables a partial rebinding and instantiation of the bound variables in a
-- 'Scope'.
rebind :: Functor f => (b -> Var b' (f a)) -> Scope b f a -> Scope b' f a
rebind f = Scope . fmap (unvar f F) . unscope

-- | Helper function for when you wish to run an action on a smashed version of
-- a scope. Transforms traversals for generality.
inScope :: (Functor f, Monad t)
        => (t (Var b a) -> f (t (Var b a))) -> Scope b t a -> f (Scope b t a)
inScope action = fmap toScope . action . fromScope

_Scope :: Iso (Scope b f a) (Scope b' f' a') (f (Var b (f a))) (f' (Var b' (f' a')))
_Scope = iso unscope Scope
