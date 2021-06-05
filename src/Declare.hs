module Declare where

import Data.Maybe (fromJust)
import Data.List (intersperse)
import Prelude hiding (LT, GT, EQ)

data BinaryOp = Add | Sub | Mult | Div
              | And | Or  | GT   | LT  | LE
              | GE  | EQ
              deriving (Eq)

data UnaryOp = Neg
             | Not
             deriving Eq

data Var = Var String
  deriving (Eq)

data Label = Label String
  deriving (Eq)  

data SMethod = SMethod Var Exp
  deriving Eq


data Exp = SLit Int
         | SBool Bool
         | SUnary UnaryOp Exp
         | SBin BinaryOp Exp Exp
         | SIf Exp Exp Exp
         | SVar Var
         | Lam Var Exp
         | Apply Exp Exp
         | SClone Exp
         | SObject [(Label, SMethod)]
         | SCall Exp Label
         | SUpdate Exp Label SMethod
         | SLet Var Exp Exp
         | Top
         | Class [(Label, SMethod)] Exp
         | SNew Exp
         deriving Eq


data Method = Method Var SigmaTerm
  deriving Eq

data MethodClosure = Closure Env Var SigmaTerm
  deriving Eq
  
data SigmaTerm = SigmaVar Var
  | Object [(Label, Method)]
  | Call SigmaTerm Label
  | Update SigmaTerm Label Method
  | Let Var SigmaTerm SigmaTerm
  | Clone SigmaTerm
  | Lit Int
  | Boolean Bool
  | Binary BinaryOp SigmaTerm SigmaTerm
  | Unary UnaryOp SigmaTerm 
  | If SigmaTerm SigmaTerm SigmaTerm
  deriving Eq

data Value = VInt Int | VBool Bool | ObjRef Int | ClosureX SigmaTerm Env [[(Label, MethodClosure)]] deriving Eq

instance Show Value where
  show (VInt i)             = show i
  show (VBool b)            = show b
  show (ClosureX e env mem) = "ClosureX"
  {-
  show (VClosure env ms)  =
    "<" ++ show env ++ ", " ++ (show $ map (\(l,m) -> show l ++ " = " ++ show m) ms)
  -}
  show (ObjRef i)           = "@" ++ show i

type Env = [(Var, Value)]

-- Pretty printer

instance Show SMethod where
  show (SMethod v  a) = case v of 
    Var "_" -> show a
    _ -> "{" ++ show v  ++ "} " ++ show a

instance Show BinaryOp where
  show Add = "+"
  show Sub = "-"
  show Mult = "*"
  show Div = "/"
  show And = "&&"
  show Or = "||"
  show GT = ">"
  show LT = "<"
  show LE = "<="
  show GE = ">="
  show EQ = "=="

instance Show UnaryOp where
  show Neg = "-"
  show Not = "!"

instance Show Label where
  show (Label x) = x

instance Show Var where
  show (Var x) = x

instance Show Exp where
  show (SObject ms) = "[" ++ (concat $ 
    (intersperse ", " 
    (map (\(l,m) -> show l ++ "=" ++ show m) ms))) 
    ++ "]"
  show (SCall a l) = (show' a) ++ "." ++ (show l)
    where show' a'@(SUpdate _ _ _) = "(" ++ show a' ++ ")"
          show' a' = show a'
  show (SUpdate a l m) = (show' a) ++ "." ++ (show l) ++ "<~" ++ (show m)
    where show' a'@(SUpdate _ _ _) = "(" ++ show a' ++ ")"
          show' a' = show a'
  show (Class ms father) = "class {" ++ (concat $ 
    (intersperse "," 
    (map (\(l,m) -> show l ++ "=" ++ show m) ms))) 
    ++ "}" ++ case father of
      Top -> ""
      (SVar x) -> show x
      (Class _ _) ->   " extends " ++ (show father) 
      _ -> error "Wrong Class Definition"
  show (SLit c)         = show c
  show (SVar c)         = show c
  show (SBool c)        = show c
  show (SBin op a b)    = show a ++ " " ++ show op ++ " " ++ show b
  show (SUnary op a)    = show op ++ "(" ++ show a ++ ")"
  show (SLet x e1 body) = "var " ++ show x ++ " = " ++ show e1 ++ "; " ++ show body
  show (SIf x1 x2 x3)   = "if (" ++ show x1 ++ ") then " ++ show x2 ++ " else " ++ show x3
  show (Lam x b)        = "\\" ++ show x ++ " -> " ++ show b 
  show (Apply e1 e2)    = show e1 ++ "(" ++ show e2 ++ ")"
  show (SClone c)       =  "clone(" ++ (show c) ++ ")"
  show (SNew c)         = "(new " ++ (show c) ++ ")"
  show (Top)            = ""
  

instance Show Method where
  show (Method (Var s) t) = "{" ++ s ++ "} " ++ show t 

instance Show MethodClosure where
  show (Closure env (Var s) t) = "<<" ++ show env ++ ", {" ++ s ++ "} " ++ show t ++ ">>" 


instance Show SigmaTerm where
  show (SigmaVar v) = show v
  show (Object ms) = "[" ++ (concat $ 
    (intersperse "," 
    (map (\(l,m) -> show l ++ "=" ++ show m) ms))) 
    ++ "]"
  show (Call a l) = (show' a) ++ "." ++ (show l)
    where show' a'@(Update _ _ _) = "(" ++ show a' ++ ")" -- if the object being passed is to be updated first then do this case - putting into brackets for better visualization
          show' a' = show a' -- otherwise just use this normal case
  show (Update a l m) = (show' a) ++ "." ++ (show l) ++ "<~" ++ (show m)
    where show' a'@(Update _ _ _) = "(" ++ show a' ++ ")"
          show' a' = show a'
  show (Lit l)         = show l
  show (Boolean b)     = show b
  show (Unary op x)    = show op ++ "(" ++ show x ++ ")"
  show (Binary op a b) = show a ++ " " ++ show op ++ " " ++ show b
  show (If x1 x2 x3)   = "if (" ++ show x1 ++ ") then " ++ show x2 ++ " else " ++ show x3
  show (Let x e1 body) = "var " ++ show x ++ " = " ++ show e1 ++ "; " ++ show body
  show (Clone c)       = "clone(" ++ show c ++ ")"