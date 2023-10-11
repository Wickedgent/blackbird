{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE LiberalTypeSynonyms #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Var where

import Control.Lens
import Data.Proxy
import Blackbird.Syntax
import Test.QuickCheck
import Test.Framework.TH
import Test.Framework.Providers.QuickCheck2

prism_yin :: Eq a => Prism' s a -> a -> Bool
prism_yin l a = preview l (review l a) == Just a

prism_yang :: Eq s => Prism' s a -> s -> Bool
prism_yang l s = maybe s (review l) (preview l s) == s

isPrism :: (Arbitrary s, Arbitrary a, Show s, Show a, Eq s, Eq a)
      => Prism' s a -> Property
isPrism l = prism_yin l .&. prism_yang l

var_1 :: (Applicative t, Eq (t a)) => Prism' (t a) a -> a -> Bool
var_1 v a = review v a == pure a

var_2 :: (Applicative t, Eq a) => Prism' (t a) a -> a -> Bool
var_2 v a = preview v (pure a) == Just a

isVariable :: (Applicative t, Arbitrary (t a), Arbitrary a, Show (t a), Show a, Eq (t a), Eq a) => Prism' (t a) a -> Property
isVariable v = isPrism v .&. var_1 v .&. var_2 v

variable :: forall p t a. (Variable t, Applicative t, Arbitrary (t a), Arbitrary a, Show (t a), Show a, Eq (t a), Eq a) => p (t a) -> Property
variable _ = isVariable (_Var :: Prism' (t a) a)

prop_var_list  = variable (Proxy :: Proxy [Int])
prop_var_maybe = variable (Proxy :: Proxy (Maybe Char))

tests = $testGroupGenerator
