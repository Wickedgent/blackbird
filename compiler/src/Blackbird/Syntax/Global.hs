{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveDataTypeable #-}
--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett 2011
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable (DeriveDataTypeable)
--
--------------------------------------------------------------------
module Blackbird.Syntax.Global
  (
  -- * Globals
    Global(Global)
  , AsGlobal(..)
  , HasGlobal(..)
  -- * Fixity
  , Assoc(..)
  , Fixity(..)
  , _Fixity
  , fixityLevel
  , unpackFixity
  , packFixity
  -- * Combinators
  , glob
  ) where

import Control.Lens
import Control.Monad
import Crypto.Hash.MD5 as MD5
import Data.Binary (Binary)
import qualified Data.Binary as Binary
import Data.Bits
import Data.Bytes.Get
import Data.Bytes.Put
import Data.Bytes.Serial
import Data.ByteString
import Data.Data (Data)
import Data.Function (on)
import Data.Hashable
import Data.Serialize (Serialize)
import qualified Data.Serialize as Serialize
import Data.Text
import Data.Word
import Blackbird.Syntax.Digest
import Blackbird.Syntax.ModuleName
import Blackbird.Syntax.Name
import GHC.Generics (Generic)

------------------------------------------------------------------------------
-- Associativity
------------------------------------------------------------------------------

-- | The associativity of an infix identifier
data Assoc = L | R | N deriving (Eq,Ord,Show,Read,Enum,Data,Generic)

instance Digestable Assoc

------------------------------------------------------------------------------
-- Fixity
------------------------------------------------------------------------------

-- | The fixity of an identifier
data Fixity
  = Infix !Assoc !Int
  | Prefix !Int
  | Postfix !Int
  | Idfix
  deriving (Eq,Ord,Show,Read,Data,Generic)

fixityLevel :: Fixity -> Maybe Int
fixityLevel (Infix _ i) = Just i
fixityLevel (Prefix i) = Just i
fixityLevel (Postfix i) = Just i
fixityLevel Idfix = Nothing

-- | Pack 'Fixity' into a 'Word8'.
--
-- Format:
--
-- >  01234567
-- >  ccaapppp
--
-- @cc@ is constructor tag, @0-3@
-- @pppp@ is precedence level, @0-9@
-- @aa@ is associativity tag, @0-2@
packFixity :: Fixity -> Word8
packFixity Idfix       = 0xC0
packFixity (Prefix  n) = 0x40 .|. (0x0F .&. fromIntegral n)
packFixity (Postfix n) = 0x80 .|. (0x0F .&. fromIntegral n)
packFixity (Infix a n) = packAssoc a .|. (0x0F .&. fromIntegral n)
 where
 packAssoc L = 0x00
 packAssoc R = 0x10
 packAssoc N = 0x20
{-# INLINE packFixity #-}

-- this should be MonadPlus, but Get isn't
unpackFixity :: MonadFail m => Word8 -> m Fixity
unpackFixity w8 =
  case 0xC0 .&. w8 of
    0x00 -> case 0x30 .&. w8 of
      0x00 -> return $ Infix L n
      0x10 -> return $ Infix R n
      0x20 -> return $ Infix N n
      _    -> fail "unpackFixity: bad associativity"
    0x40 -> return $ Prefix n
    0x80 -> return $ Postfix n
    0xC0 -> return Idfix
    _    -> fail "unpackFixity: IMPOSSIBLE"
 where n :: Int
       n = fromIntegral $ 0x0F .&. w8
{-# INLINE unpackFixity #-}

_Fixity :: Prism' Word8 Fixity
_Fixity = prism' packFixity unpackFixity
{-# INLINE _Fixity #-}

instance Serial Fixity where
  serialize f = putWord8 $ packFixity f
  deserialize = do
    w <- getWord8
    unpackFixity w

instance Binary Fixity where
  put = serialize
  get = deserialize

instance Serialize Fixity where
  put = serialize
  get = deserialize

instance Digestable Fixity

------------------------------------------------------------------------------
-- Global
------------------------------------------------------------------------------

-- | A 'Global' is a full qualified top level name.
--
-- /NB:/ You should construct these with 'global' and only use the constructor for pattern matching.
data Global = Global
  { _globalDigest   :: !ByteString
  , _globalFixity   :: !Fixity
  , _globalModule   :: !ModuleName
  , _globalName     :: !Text
  } deriving (Data, Generic)

instance Show Global where
  showsPrec d (Global _ f m n) = showParen (d > 10) $
    showString "glob " . showsPrec 11 f .
      showChar ' ' . showsPrec 11 m .
      showChar ' ' . showsPrec 11 n

instance Read Global where
  readsPrec d = readParen (d > 10) $ \r -> do
    ("glob", r') <- lex r
    (f, r'') <- readsPrec 11 r'
    (m, r''')  <- readsPrec 11 r''
    (n, r'''') <- readsPrec 11 r'''
    return (glob f m n, r'''')

instance Serial Global where
  serialize (Global d f m n) = serialize d >> serialize f >> serialize m >> serialize n
  deserialize = liftM4 Global deserialize deserialize deserialize deserialize

instance Binary Global where
  put = serialize
  get = deserialize

instance HasModuleName Global where
  moduleName g (Global _ f m n) = g m <&> \m' -> glob f m' n

instance HasName Global where
  name g (Global _ f m n) = g n <&> \n' -> glob f m n'


------------------------------------------------------------------------------
-- AsGlobal
------------------------------------------------------------------------------

class AsGlobal t where
  _Global :: Prism' t Global

instance AsGlobal Global where
  _Global = id

------------------------------------------------------------------------------
-- HasGlobal
------------------------------------------------------------------------------

class HasGlobal t where
  global :: Lens' t Global
  -- | A lens that will read or update the fixity (and compute a new digest)
  fixity :: Lens' t Fixity
  fixity f = global $ \ (Global _ a m n) -> (\a' -> glob a' m n) <$> f a

instance HasGlobal Global where
  global = id

instance Eq Global where
  (==) = (==) `on` _globalDigest

instance Ord Global where
  compare = compare `on` _globalDigest

instance Digestable Global where
  digest c = digest c . _globalDigest

instance Hashable Global where
  hashWithSalt s c = hashWithSalt s (_globalDigest c)

------------------------------------------------------------------------------
-- Combinators
------------------------------------------------------------------------------

-- | Construct a 'Global' with a correct digest.
glob :: AsGlobal t => Fixity -> ModuleName -> Text -> t
glob f m n = _Global # Global d f m n where
  d = MD5.finalize $ digest MD5.init f `digest` m `digest` n
