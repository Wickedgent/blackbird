{-# LANGUAGE CPP, ForeignFunctionInterface #-}
{-# OPTIONS_GHC "-Wno-redundant-constraints" #-} -- don't want USE_CP to change types
--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett and Dan Doel 2012-2013
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable
--
--------------------------------------------------------------------
module Blackbird.Console.Unicode
  ( withUnicode
  ) where

import Control.Monad.Catch

##ifdef mingw32_HOST_ARCH
##ifdef i386_HOST_ARCH
##define USE_CP
import Control.Monad.IO.Class
import System.IO
import Foreign.C.Types
foreign import stdcall "windows.h SetConsoleCP" c_SetConsoleCP :: CUInt -> IO Bool
foreign import stdcall "windows.h GetConsoleCP" c_GetConsoleCP :: IO CUInt
##elif defined(x86_64_HOST_ARCH)
##define USE_CP
import Control.Monad.IO.Class
import System.IO
import Foreign.C.Types
foreign import ccall "windows.h SetConsoleCP" c_SetConsoleCP :: CUInt -> IO Bool
foreign import ccall "windows.h GetConsoleCP" c_GetConsoleCP :: IO CUInt
##endif
##endif

-- | Run in a modified codepage where we can print UTF-8 values on Windows.
--
-- You should probably run the top level of your program in this.
withUnicode :: MonadCatch m => m a -> m a
##ifdef USE_CP
withUnicode m = do
  cp <- liftIO c_GetConsoleCP
  enc <- liftIO $ hGetEncoding stdout
  let setup = liftIO $ c_SetConsoleCP 65001 >> hSetEncoding stdout utf8
      cleanup = liftIO $ maybe (return ()) (hSetEncoding stdout) enc >> c_SetConsoleCP cp
  finally (setup >> m) cleanup
##else
withUnicode m = m
##endif
