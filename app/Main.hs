module Main where

import System.Environment (getArgs)
import Data.Maybe (fromJust)
import Data.List (isPrefixOf)
import System.Exit

import Prelude hiding (LT, GT, EQ)
import System.Directory
import System.IO
import Parser
import Declare
import TargetMonads
import Source

import System.Console.Repline
import Control.Monad.State.Strict

type Repl a = HaskelineT IO a


-- Execute
exec :: String -> Repl ()
exec src = do
  let exp = parseExpr src
  case exp of
    Right t  -> (do
      let val = execute (translate t []) --execute a
      liftIO $ putStrLn $ show val)
    Left err -> liftIO $ putStrLn $ err


-- :exit command
exit :: a -> Repl ()
exit _ = do
  liftIO $ putStrLn "Exiting sigmacalc..."
  liftIO $ exitSuccess


-- Prefix tab completer | :run <filename> auto completer
defaultMatcher :: MonadIO m => [(String, CompletionFunc m)]
defaultMatcher = [(":run"  , fileCompleter)]


-- Default tab completer
comp :: Monad m => WordCompleter m
comp x = do
  let cmd = [":exit", ":run"]
  return $ filter (isPrefixOf x) cmd

-- Auto completer 
completer :: CompleterStyle IO
completer = Prefix (wordCompleter comp) defaultMatcher


bannerMsg :: Repl ()
bannerMsg = do
  liftIO $ putStrLn $ "Welcome to SigmaCalculus"


ban :: MultiLine -> Repl String
ban SingleLine = pure "sigmacalc>> "
ban MultiLine  = pure "... "


opts :: [(String, String -> Repl ())]
opts = [
            ("run", run),
            ("exit", exit)
        ]


final :: Repl ExitDecision
final = do
  liftIO $ putStrLn "Exiting sigmacalc..."
  return Exit


-- :run command
run :: String -> Repl ()
run args = do
  contents <- liftIO $ readFile (unwords [args])
  exec contents


callShell :: Repl a -> IO ()
callShell pre =  evalRepl ban exec opts (Just ':') (Just "|") completer pre final


loadFile :: String -> IO ()
loadFile fname = do
  src <- liftIO $ readFile fname
  let e = parseExpr src
  case e of
    Right t -> (do
      let value = execute (translate t [])
      liftIO $ putStrLn $ show value)
    Left err -> liftIO $ putStrLn $ err


main :: IO ()
main = do
  arguments <- getArgs
  case arguments of
    []      -> callShell bannerMsg
    [fname] -> loadFile fname
    _       -> do
          putStrLn "Error: Invalid arguments. Please consult provided documentation!"