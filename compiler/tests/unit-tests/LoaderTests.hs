{-# LANGUAGE OverloadedStrings #-}
module LoaderTests (main) where

import Control.Lens
import Control.Monad (forM_)
import Control.Monad.Trans.Except
import Data.Functor (void)
import Data.Text (Text, pack)
import qualified Data.Text.IO as TIO
import Blackbird.Loader.Core
import Blackbird.Loader.Filesystem
import System.FilePath ((</>))
import Test.Framework.Providers.API
import Test.Framework.Providers.HUnit
import Test.HUnit

import ParserTests (stdLibDir)

stdLibLoader :: Loader Freshness (ExceptT LoadRefusal IO) String Text
stdLibLoader = contramapName pack $ filesystemLoader stdLibDir "e"

loadsAFile = do fraw <- TIO.readFile (stdLibDir </> "Byte.e")
                lr <- (stdLibLoader ^. load) "Byte" & runExceptT
                assertEqual "load result" (Right fraw) (fmap snd lr)

recognizesBadNames =
  [".Byte", "Byte.", "Control..Monad", "Control/Monad", "Control\NULMonad", ""]
   `forM_` \modName -> do
    let badMod :: Either LoadRefusal a -> Assertion
        badMod = assertEqual ("Not a valid module name: " ++ modName)
                             (Left NoFilenameMapping) . void
    lr <- (stdLibLoader ^. load) modName & runExceptT
    badMod lr
    rr <- (stdLibLoader ^. reload) modName undefined & runExceptT
    badMod rr

recognizesMissingFiles = do
  let modName = "Control.NotAModuleNoSiree"
      exFile = stdLibDir </> "Control" </> "NotAModuleNoSiree.e"
  lr <- (stdLibLoader ^. load) modName & runExceptT
  assertEqual "loader recognizes missing files"
    (Left (FileNotFound exFile)) (void lr)
  rr <- (stdLibLoader ^. reload) modName undefined & runExceptT
  assertEqual "reloader recognizes missing files"
    (Left (FileNotFound exFile)) (void lr)

cachesWhenCacheable = do
  let modname = "Byte"
  Right (freshness, _) <- (stdLibLoader ^. load) modname & runExceptT
  reloaded <- (stdLibLoader ^. reload) modname freshness & runExceptT
  assertEqual "cache hit" (Right Nothing) (fmap (fmap snd) reloaded)

main = TestGroup "LoaderTests"
  [ testCase "loads a file" loadsAFile
  , testCase "recognizes bad names" recognizesBadNames
  , testCase "recognizes missing files" recognizesMissingFiles
  , testCase "caches when cacheable" cachesWhenCacheable
  ]
