{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveDataTypeable #-}
--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett and Dan Doel 2013-2014
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable
--
--------------------------------------------------------------------
module Blackbird.Syntax.Head
  ( Head(..)
  , HasHead(..)
  , mkHead
  ) where

import Control.Lens
import Crypto.Hash.MD5 as MD5 hiding (hash)
import Data.Binary (Binary)
import Data.ByteString
import Data.Bytes.Serial
import Data.Data
import Data.Function
import Data.Hashable
import Data.Serialize (Serialize)
import Blackbird.Syntax.Digest
import Blackbird.Syntax.Global
import Blackbird.Syntax.Kind
import Blackbird.Syntax.Type
import GHC.Generics
import qualified Data.Binary as Binary
import qualified Data.Serialize as Serialize

------------------------------------------------------------------------------
-- Head
------------------------------------------------------------------------------

-- | In the instance declaration:
--
-- @
--   instance Foo a => Bar Int [a] where
--     ...
-- @
--
-- The portion @Bar Int [a]@ is the head of the instance. All instances
-- must have a unique head; type class dispatch does not take the context
-- of the instance into account. Thus, instances are uniquely identified by
-- their heads, and we use them for that purpose among others.
--
-- The Head type records all the information necessary for this unique
-- identification, plus a hash for fast equality checks.
--
-- The above instance head would be represented as something like:
--
-- @
--   Head ... "Bar" 0 [star] [] [int, list (B 0)]
-- @

data Head = Head { _headDigest     :: ByteString
                 , _hash           :: !Int
                 , _headClass      :: !Global    -- ^ The class name for which this is an instance
                 , _headBoundKinds :: !Int       -- ^ number of kind variables brought into scope
                 , _headBoundTypes :: [Kind Int] -- ^ kinds of type variables brought into scope
                 , _headKindArgs   :: [Kind Int]
                 , _headTypeArgs   :: [Typ Int Int]
                 }
  deriving (Show,Read,Generic,Data)

instance Eq Head where
  (==) = (==) `on` _headDigest

instance Ord Head where
  compare = compare `on` _headDigest

instance HasGlobal Head where
  global f = head_ $ \(Head _ _ g i tks ks ts) -> f g <&> \g' -> mkHead g' i tks ks ts

mkHead :: Global -> Int -> [Kind Int] -> [Kind Int] -> [Typ Int Int] -> Head
mkHead g i tks ks ts = Head d h g i tks ks ts
 where
 d = MD5.finalize $ digest MD5.init g `digest` i `digest` tks `digest` ks `digest` ts
 h = hash g `hashWithSalt` i `hashWithSalt` tks `hashWithSalt` ks `hashWithSalt` ts
{-# INLINE mkHead #-}

class HasHead t where
  head_         :: Lens' t Head

  headClass     :: Lens' t Global
  headClass f = head_ $ \(Head _ _ g i tks ks ts) -> f g <&> \g' -> mkHead g' i tks ks ts

  headBoundKinds :: Lens' t Int
  headBoundKinds f = head_ $ \(Head _ _ g i tks ks ts) -> f i <&> \i' -> mkHead g i' tks ks ts

  headBoundTypes :: Lens' t [Kind Int]
  headBoundTypes f = head_ $ \(Head _ _ g i tks ks ts) -> f tks <&> \tks' -> mkHead g i tks' ks ts

  headKindArgs :: Lens' t [Kind Int]
  headKindArgs f = head_ $ \(Head _ _ g i tks ks ts) -> f ks <&> \ks' -> mkHead g i tks ks' ts

  headTypeArgs :: Lens' t [Typ Int Int]
  headTypeArgs f = head_ $ \(Head _ _ g i tks ks ts) -> f ts <&> \ts' -> mkHead g i tks ks ts'

instance HasHead Head where
  head_ = id

instance Hashable Head where
  hashWithSalt n Head{_hash = h} = hashWithSalt n h

instance Binary Head where
  put = serialize
  get = deserialize

instance Serialize Head where
  put = serialize
  get = deserialize

instance Digestable Head where
  digest c Head{_headDigest = d} = update c d

instance Serial Head where
  serialize h =
    serialize (_headDigest h)     >>
    serialize (_hash h)           >>
    serialize (h^.headClass)      >>
    serialize (h^.headBoundKinds) >>
    serialize (h^.headBoundTypes) >>
    serialize (h^.headKindArgs)   >>
    serialize (h^.headTypeArgs)
  deserialize =
    Head <$> deserialize <*> deserialize <*> deserialize <*> deserialize <*> deserialize <*> deserialize <*> deserialize
