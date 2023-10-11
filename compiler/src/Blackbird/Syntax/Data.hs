{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE MultiParamTypeClasses #-}
--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett and Dan Doel 2012-2014
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable (DeriveDataTypeable)
--
-- This module provides the AST for data type declarations
--------------------------------------------------------------------

module Blackbird.Syntax.Data
  ( DataType(DataType)
  , kparams
  , tparams
  , typeParameters
  , constrs
  , constructors
  , dataTypeCon
  ) where

import Bound
import Bound.Var
import Bound.Scope
import Control.Comonad
import Control.Lens
import Data.Bifoldable
import Data.Bitraversable
import Data.Binary as Binary
import Data.Bytes.Serial
import Data.Serialize as Serialize
import Data.Void
import Blackbird.Syntax
import Blackbird.Syntax.Constructor
import Blackbird.Syntax.Hint
import Blackbird.Syntax.Global
import Blackbird.Syntax.Kind as Kind
import Blackbird.Syntax.Name
import Blackbird.Syntax.Scope
import Blackbird.Syntax.Type as Type
import GHC.Generics hiding (Constructor)
import Prelude.Extras

data DataType k t =
  DataType { _dtname  :: Global
           , _kparams :: [Hint]
           , _tparams :: [(Hint, Scope Int Kind k)]
           , _constrs :: [Constructor (Var Int k) (Var Int t)]
           }
  deriving (Show, Eq, Foldable, Traversable, Functor, Generic)

instance HasGlobal (DataType k t) where
  global = lens _dtname (\dt g -> dt { _dtname = g })

instance HasName (DataType k t) where
  name = global.name

kparams :: Lens' (DataType k t) [Hint]
kparams = lens _kparams (\dt ks -> dt { _kparams = ks })

tparams :: Lens' (DataType k t) [(Hint, Scope Int Kind k)]
tparams = lens _tparams (\dt ks -> dt { _tparams = ks })

typeParameters :: Traversal' (DataType k t) ((Hint, Scope Int Kind k))
typeParameters = tparams.traverse

constrs :: Lens (DataType k t)
                (DataType k u)
                [Constructor (Var Int k) (Var Int t)]
                [Constructor (Var Int k) (Var Int u)]
constrs = lens _constrs (\dt ks -> dt { _constrs = ks })

constructors :: Traversal (DataType k t)
                          (DataType k u)
                          (Constructor (Var Int k) (Var Int t))
                          (Constructor (Var Int k) (Var Int u))
constructors = constrs.traverse

dataTypeCon :: DataType Void t -> HardType
dataTypeCon dt = Con (dt^.global) (schema dt)

instance Schematic (DataType k t) k where
  schema dt =
    Schema (dt^.kparams) (Scope . foldr (~>) star $ unscope . extract <$> dt^.tparams)

instance BoundBy (DataType k) (Typ k) where
  boundBy f = over constructors . boundBy $ unvar (pure . B) (bimap F F . f)

instance Show k => Show1 (DataType k)
instance Show2 DataType

instance Eq k => Eq1 (DataType k)
instance Eq2 DataType

instance Bifunctor DataType where bimap = bimapDefault
instance Bifoldable DataType where bifoldMap = bifoldMapDefault

instance Bitraversable DataType where
  bitraverse f g (DataType nm ks ts cs) =
    DataType nm ks
      <$> traverse (traverse $ traverseScope pure f) ts
      <*> traverse (bitraverse (traverse f) (traverse g)) cs

instance HasKindVars (DataType k t) (DataType k' t) k k' where
  kindVars f (DataType nm ks ts cs) =
    DataType nm ks
      <$> (traverse.traverse.kindVars) f ts
      <*> (traverse.kindVars.traverse) f cs

instance HasTypeVars (DataType k t) (DataType k t') t t' where
  typeVars = traverse

instance Serial2 DataType where
  serializeWith2 pk pt (DataType nm ks ts cs) =
    serialize nm *>
    serialize ks *>
    serializeWith (serializeWith $ serializeScope3 serialize serializeWith pk) ts *>
    serializeWith (serializeWith2 (serializeWith pk) (serializeWith pt)) cs

  deserializeWith2 gk gt =
    DataType
      <$> deserialize
      <*> deserialize
      <*> deserializeWith
            (deserializeWith $ deserializeScope3 deserialize deserializeWith gk)
      <*> deserializeWith (deserializeWith2 (deserializeWith gk) (deserializeWith gt))

instance Serial k => Serial1 (DataType k) where
  serializeWith = serializeWith2 serialize
  deserializeWith = deserializeWith2 deserialize

instance (Serial k, Serial t) => Serial (DataType k t) where
  serialize = serializeWith serialize
  deserialize = deserializeWith deserialize

instance (Binary k, Binary t) => Binary (DataType k t) where
  get = deserializeWith2 Binary.get Binary.get
  put = serializeWith2 Binary.put Binary.put

instance (Serialize k, Serialize t) => Serialize (DataType k t) where
  get = deserializeWith2 Serialize.get Serialize.get
  put = serializeWith2 Serialize.put Serialize.put
