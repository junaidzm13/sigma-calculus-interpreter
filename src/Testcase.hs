module Testcase where

import Parser
import Declare
import Target
import Source

-- For testing evaluateByNeed
testEvalByNeed :: String -> SigmaTerm
testEvalByNeed exp = 
    case parseExpr exp of
      Right st -> executeByNeed (translate st [])
      _        -> error ("Parse error")

-- For testing evaluateS
testEval :: String -> SigmaTerm
testEval exp = 
    case parseExpr exp of
      Right st -> execute (translate st [])
      _        -> error ("Parse error")

-- For testing translate
printExpr :: String -> SigmaTerm
printExpr e = case parseExpr e of
    Right s -> translate (s) []
    _ -> error("error")


-- | Some Tests
-- >>> lamRaw <- readFile "test/testcases/lam.obj"
-- >>> Right lam = parseExpr lamRaw
-- >>> execute (translate lam [])
-- 11
-- >>> cellRaw <- readFile "test/testcases/cell.obj"
-- >>> Right cell = parseExpr cellRaw
-- >>> execute (translate cell [])
-- 3
-- >>> gcellRaw <- readFile "test/testcases/gcell.obj"
-- >>> Right gcell = parseExpr gcellRaw
-- >>> execute (translate gcell [])
-- 7
-- >>> uncellRaw <- readFile "test/testcases/uncell.obj"
-- >>> Right uncell = parseExpr uncellRaw
-- >>> execute (translate uncell [])
-- 5
-- >>> calcEx1Raw <- readFile "test/testcases/calcEx1.obj"
-- >>> Right calcEx1 = parseExpr calcEx1Raw
-- >>> execute (translate calcEx1 [])
-- 5
-- >>> calcEx2Raw <- readFile "test/testcases/calcEx2.obj"
-- >>> Right calcEx2 = parseExpr calcEx2Raw
-- >>> execute (translate calcEx2 [])
-- 10
-- >>> calcEx3Raw <- readFile "test/testcases/calcEx3.obj"
-- >>> Right calcEx3 = parseExpr calcEx3Raw
-- >>> execute (translate calcEx3 [])
-- 11
-- >>> cellClassRaw <- readFile "test/testcases/cellClass.obj"
-- >>> Right cellClass = parseExpr cellClassRaw
-- >>> execute (translate cellClass [])
-- 3
-- >>> gcellClassRaw <- readFile "test/testcases/gcellClass.obj"
-- >>> Right gcellClass = parseExpr gcellClassRaw
-- >>> execute (translate gcellClass [])
-- 5
-- >>> uncellClassRaw <- readFile "test/testcases/uncellClass.obj"
-- >>> Right uncellClass = parseExpr uncellClassRaw
-- >>> execute (translate uncellClass [])
-- 3