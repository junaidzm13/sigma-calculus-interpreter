module TargetMonads where
import Prelude hiding (LT, GT, EQ)
import Parser
import Declare
import Data.List
import Data.Maybe
import Control.Monad.Fail


-- required in the latest versions of GHC
instance Functor Checked
instance Applicative Checked

type Object = [(Label, MethodClosure)]

type Mem = [Object]

-- Definition of Checked
data Checked a = Good a | Error String
  deriving Show

instance Monad Checked where
  -- return :: a -> Checked a
  return x = Good x
  -- (>>=) :: Checked a -> (a -> Checked b) -> Checked b
  x >>= f =
    case x of
       Error msg -> Error msg
       Good v -> f v

-- instance Show a => Show (Checked a) where
--     show a = 
--       case a of
--         Good x    -> show x
--         Error msg -> msg

instance Functor StatefulChecked
instance Applicative StatefulChecked


-- Definiton of StatefulChecked Monad
instance Monad (StatefulChecked) where
  -- return :: a -> StatefulChecked a
  return val = ST (\m -> Good (val, m))
  -- (>>=) :: StatefulChecked a -> (a -> StatefulChecked b) -> StatefulChecked b
  (ST c) >>= f = 
    ST (\m -> 
        case c m of
            Good x    -> let (val, m') = x in
                let ST f' = f val in
                    f' m'
            Error msg -> (\m -> Error msg) m
      )
  
data StatefulChecked a = ST (Mem -> Checked (a, Mem))

instance Show a => Show (StatefulChecked a) where
    show (ST f) = 
      case (f []) of
        Good (a, mem) -> show a
        Error msg     -> msg


-- Takes a Checked Value and transforms it into StatefulChecked Value
checkedReturn :: Checked Value -> StatefulChecked Value
checkedReturn (Good val)  = ST (\m -> Good (val, m))
checkedReturn (Error msg) = ST (\m -> Error msg)


{-
The type Mem is a model of memory: it is used to store objects in memory.
For this language we have to have memory, just as in the interpreter
with mutable state, because objects are mutable. That is, the method
update operation can actually modify methods stored in objects.

Therefore the memory stores all the objects that are allocated in the program.
-}

{- The replace operation, updates a method for an object in memory -}
replace :: Int -> Label -> MethodClosure -> Mem -> Mem
replace i l closure mem =
    let (before, o : after) = splitAt i mem in
    before ++ [[if (l == n) then (n, closure) else (n,c) | (n,c) <- o]] ++ after


-- unaryChecked and binaryChecked helper functions
unaryChecked :: UnaryOp -> Value -> Checked Value
unaryChecked Not (VBool b) = Good (VBool (not b))
unaryChecked Neg (VInt i)  = Good (VInt (-i))
unaryChecked op x = Error ("Type error: Cannot apply operator " ++ show op  ++ " to " ++ show x ++ " - Incompatible operator and operand type!") 

binaryChecked :: BinaryOp -> Value -> Value -> Checked Value
binaryChecked Add (VInt a) (VInt b)   = Good (VInt (a + b))
binaryChecked Sub (VInt a) (VInt b)   = Good (VInt (a - b))
binaryChecked Mult (VInt a) (VInt b)  = Good (VInt (a * b))
binaryChecked Div (VInt a) (VInt 0)   = Error ("Division by zero error: " ++ show a ++ " / 0")
binaryChecked Div (VInt a) (VInt b)   = Good (VInt (a `div` b))
binaryChecked And (VBool a) (VBool b) = Good (VBool (a && b))
binaryChecked Or (VBool a) (VBool b)  = Good (VBool (a || b))
binaryChecked LT (VInt a) (VInt b)    = Good (VBool (a < b))
binaryChecked LE (VInt a) (VInt b)    = Good (VBool (a <= b))
binaryChecked GE (VInt a) (VInt b)    = Good (VBool (a >= b))
binaryChecked GT (VInt a) (VInt b)    = Good (VBool (a > b))
binaryChecked EQ a b                  = Good (VBool (a == b))
binaryChecked op a b                  = Error ("Type error: Cannot apply operator " ++ show op ++ " to " ++ show a ++ " & " ++ show b ++ " - Incompatible operator and operands type!")


-- Access the Object in memory mem at position i
access :: Int -> Mem -> Object
access i mem = mem !! i


-- Check whether the Value is of form VBool cond, in this case return Good cond else ouput Error msg.
condChecked :: Value -> Checked Bool
condChecked (VBool cond) = Good cond
condChecked x            = Error ("Type error: The expression: "  ++
                     show x ++ " is not a boolean!")


-- Check whether the Value is of form ObjRef i, in this case return Good i else ouput Error msg.
objectChecked :: Value -> Checked Int
objectChecked (ObjRef i) = Good i
objectChecked x          = Error ("Type error: The expression: "  ++
                                 show x ++ " is not an object reference!")
{- Evaluation takes the following arguments:

SigmaTerm: The expression to be evaluated
Env: The current environment
Mem: The current memory

and returns the following:

Value: The value that is computed
Mem: The updated memory (in case method update operations have been performed)

-}

-- EVALUATE WITH STATEFULCHECKED MONAD (ADDITIONAL FEATURE)
-- This evaluator is the one directly linked / used by the implemented interpreter. 

-- Extending memory by adding obj at the end of the memory
newMemory :: Object -> StatefulChecked Value
newMemory obj = ST (\mem -> Good (ObjRef (length mem), mem ++ [obj]))

-- Updates memory by accessing object at index i of memory, and updating its method l.
updateMemory :: Int -> Label -> MethodClosure -> StatefulChecked Value
updateMemory i l closure = ST (\mem -> let (before, o : after) = splitAt i mem in
                                       Good (ObjRef i, before ++ [[if (l == n) then (n, closure) else (n,c) | (n,c) <- o]] ++ after))

-- Replica of access, for accessing memory at index i to retrieve an object.
readMemory :: Int -> StatefulChecked Object
readMemory i = ST (\mem -> Good (access i mem, mem))

-- cloneMemory :: Int -> Stateful MValue
-- cloneMemory i = ST (\mem -> newMemory (access i mem))

evaluateMonad :: SigmaTerm -> Env -> StatefulChecked Value
evaluateMonad (SigmaVar v) e = 
  case lookup v e of
    Just a  -> return a
    Nothing -> checkedReturn (Error ("Variable " ++ show v ++ " is undefined!"))

evaluateMonad (Object o) e =
  let mc = map (\(l, Method v t) -> (l, Closure e v t)) o in
  newMemory mc

evaluateMonad (Call a l) e = do
    objRef <- evaluateMonad a e
    case objectChecked objRef of
      Good i    -> do
                   ms <- readMemory i
                   case lookup l ms of
                     Just (Closure env v m) -> evaluateMonad m ((v,ObjRef i) : env)
                     _                      -> checkedReturn (Error ("Method not found: The method " ++ show l
                                                              ++ " was not found in: " ++ show ms))
      Error msg -> checkedReturn (Error msg)

evaluateMonad (Let x a b) e = do
  v <- evaluateMonad a e
  let newEnv = (x, v) : e in 
    evaluateMonad b newEnv

evaluateMonad (Clone a) e = do
  objRef <- evaluateMonad a e
  case objectChecked objRef of
    Good i    -> do 
                 obj <- readMemory i
                 newMemory obj
    Error msg -> checkedReturn (Error msg)

evaluateMonad (Lit a) e     = return (VInt a)
evaluateMonad (Boolean a) e = return (VBool a)                        

evaluateMonad (Update a l (Method v m)) e = do
  objRef <- evaluateMonad a e
  case objectChecked objRef of
    Good i    -> updateMemory i l (Closure e v m)
    Error msg -> checkedReturn (Error msg)

evaluateMonad (Binary op a b) e = do
  v1 <- evaluateMonad a e
  v2 <- evaluateMonad b e
  checkedReturn (binaryChecked op v1 v2)

evaluateMonad (Unary op a) e = do
  v <- evaluateMonad a e
  checkedReturn (unaryChecked op v)

evaluateMonad (If a b c) e = do
  cond <- evaluateMonad a e
  case condChecked cond of
    Good cond'   -> evaluateMonad (if cond' then b else c) e
    Error msg    -> checkedReturn (Error msg)


-- Used for the interpreter in app/Main.hs
execute :: SigmaTerm -> Checked SigmaTerm
execute e = case evaluateMonad e [] of
  ST f -> case (f []) of
            Good (ObjRef i, mem) -> revert (mem !! i)
            Good (VInt i, mem)   -> Good (Lit i)
            Good (VBool i, mem)  -> Good (Boolean i)
            Error msg            -> Error msg


revert :: Object -> Checked SigmaTerm
revert [] = Good (Object [])
revert (x:xs) = let (l, cl) = x in
  case cl of
    Closure _ y s -> let mt = Method y s in
      case revert xs of
        Good (Object ms) -> Good (Object ((l, mt):ms))
        _                -> Error "Revert function fails"
