{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}

module Blackbird.Syntax.ModuleName
  ( ModuleName(ModuleName)
  , mkModuleName
  , mkModuleName_
  , HasModuleName(..)
  ) where

import Control.Lens
import Crypto.Hash.MD5 as MD5
import Data.Binary
import Data.Bytes.Serial
import Data.ByteString
import Data.Data
import Data.Function
import Data.Hashable
import Data.Serialize
import Data.Text
import Blackbird.Syntax.Digest
import Blackbird.Syntax.Name
import GHC.Generics hiding (moduleName)

data ModuleName = ModuleName
  { _digest   :: !ByteString
  , _package  :: !Text
  , _name     :: !Text
  } deriving (Data, Generic)

mkModuleName :: Text -> Text -> ModuleName
mkModuleName p m = ModuleName d p m where
  d = MD5.finalize $ digest MD5.init p `digest` m

mkModuleName_ :: String -> ModuleName
mkModuleName_ nam = mkModuleName (Data.Text.pack "base") (Data.Text.pack nam)

instance Show ModuleName where
  showsPrec d (ModuleName _ p n) = showParen (d > 10) $
    showString "mkModuleName " . showsPrec 11 p .
                  showChar ' ' . showsPrec 11 n

instance Read ModuleName where
  readsPrec d = readParen (d > 10) $ \r -> do
    ("mkModuleName", r') <- lex r
    (p, r'') <- readsPrec 11 r'
    (n, r''')  <- readsPrec 11 r''
    return (mkModuleName p n, r''')

instance Eq ModuleName where
  (==) = (==) `on` _digest

instance Ord ModuleName where
  compare = compare `on` _digest

instance Hashable ModuleName where
  hashWithSalt s c = hashWithSalt s (_digest c)

instance HasName ModuleName
  where name f (ModuleName _ pkg nm) = mkModuleName pkg <$> f nm

class HasModuleName t where
  moduleName      :: Lens' t ModuleName

  package     :: Lens' t Text
  package f = moduleName $ \(ModuleName _ pkg nm) -> f pkg <&> \pkg' -> mkModuleName pkg' nm

instance HasModuleName ModuleName where moduleName = id

instance Digestable ModuleName where
  digest c ModuleName{_digest = d} = update c d

instance Serial ModuleName where
  serialize mn = serialize (_digest mn) >> serialize (mn^.package) >> serialize (mn^.name)
  deserialize = ModuleName <$> deserialize <*> deserialize <*> deserialize

instance Binary ModuleName where
  get = deserialize; put = serialize

instance Serialize ModuleName where
  get = deserialize; put = serialize
