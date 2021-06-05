{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_bundle (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "C:\\Users\\Junaid Zubair\\Desktop\\Semester 8\\Principles of Prog\\bundle\\.stack-work\\install\\29bcbd71\\bin"
libdir     = "C:\\Users\\Junaid Zubair\\Desktop\\Semester 8\\Principles of Prog\\bundle\\.stack-work\\install\\29bcbd71\\lib\\x86_64-windows-ghc-8.10.4\\bundle-0.1.0.0-8GI2PMiRzKG2MwdFHxfsHd-sigmac-exe"
dynlibdir  = "C:\\Users\\Junaid Zubair\\Desktop\\Semester 8\\Principles of Prog\\bundle\\.stack-work\\install\\29bcbd71\\lib\\x86_64-windows-ghc-8.10.4"
datadir    = "C:\\Users\\Junaid Zubair\\Desktop\\Semester 8\\Principles of Prog\\bundle\\.stack-work\\install\\29bcbd71\\share\\x86_64-windows-ghc-8.10.4\\bundle-0.1.0.0"
libexecdir = "C:\\Users\\Junaid Zubair\\Desktop\\Semester 8\\Principles of Prog\\bundle\\.stack-work\\install\\29bcbd71\\libexec\\x86_64-windows-ghc-8.10.4\\bundle-0.1.0.0"
sysconfdir = "C:\\Users\\Junaid Zubair\\Desktop\\Semester 8\\Principles of Prog\\bundle\\.stack-work\\install\\29bcbd71\\etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "bundle_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "bundle_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "bundle_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "bundle_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "bundle_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "bundle_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "\\" ++ name)
