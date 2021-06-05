module Target where
import Prelude hiding (LT, GT, EQ)
import Parser
import Declare
import Data.List
import Data.Maybe
import Control.Monad.Fail
-- required in the latest versions of GHC
instance Functor Stateful 
instance Applicative Stateful

-- Q4 DEFINITION OF Stateful Monad
instance Monad Stateful where
  -- return :: a -> Stateful a
  return val = ST (\m -> (val, m))
  -- (>>=) :: Stateful a -> (a -> Stateful b) -> Stateful b
  (ST c) >>= f = 
    ST (\m -> 
      let (val, m') = c m in
        let ST f' = f val in
          f' m'
      )
instance Show t => Show (Stateful t) where
    show (ST f) = 
      case (f []) of 
        (t, mem) -> show t

data Stateful t = ST (Mem -> (t, Mem))

{-

The type Mem is a model of memory: it is used to store objects in memory.
For this language we have to have memory, just as in the interpreter
with mutable state, because objects are mutable. That is, the method
update operation can actually modify methods stored in objects.

Therefore the memory stores all the objects that are allocated in the program.
-}

type Object = [(Label, MethodClosure)]

type Mem = [Object]


instance MonadFail Stateful


{- The replace operation, updates a method for an object in memory -}
replace :: Int -> Label -> MethodClosure -> Mem -> Mem
replace i l closure mem =
    let (before, o : after) = splitAt i mem in
    before ++ [[if (l == n) then (n, closure) else (n,c) | (n,c) <- o]] ++ after

{- Evaluation takes the following arguments:

SigmaTerm: The expression to be evaluated
Env: The current environment
Mem: The current memory

and returns the following:

Value: The value that is computed
Mem: The updated memory (in case method update operations have been performed)

-}
-- Q1: binary and unary helper functions.
binary :: BinaryOp -> Value -> Value -> Value
binary Add (VInt a) (VInt b)   = VInt (a + b)
binary Sub (VInt a) (VInt b)   = VInt (a - b)
binary Mult (VInt a) (VInt b)  = VInt (a * b)
binary Div (VInt a) (VInt 0)   = error ("Division by zero: " ++ show a ++ " / 0")
binary Div (VInt a) (VInt b)   = VInt (a `div` b)
binary And (VBool a) (VBool b) = VBool (a && b)
binary Or (VBool a) (VBool b)  = VBool (a || b)
binary LT (VInt a) (VInt b)    = VBool (a < b)
binary LE (VInt a) (VInt b)    = VBool (a <= b)
binary GE (VInt a) (VInt b)    = VBool (a >= b)
binary GT (VInt a) (VInt b)    = VBool (a > b)
binary EQ a b                  = VBool (a == b)
binary op a b                  = error ("Type error: Cannot apply operator " ++ show op  ++ " to " ++ show a ++ " & " ++ show b ++ " - Incompatible operator and operands type!")

unary :: UnaryOp -> Value -> Value
unary Not (VBool b) = VBool (not b)
unary Neg (VInt i)  = VInt (-i)
unary op x          = error ("Type error: Cannot apply operator " ++ show op  ++ " to " ++ show x ++ " - Incompatible operator and operand type!")

-- For accessing object in mem at position i.
access :: Int -> Mem -> Object
access i mem = mem !! i


-- DEFAULT GIVEN EVALUATE  
evaluateS :: SigmaTerm -> Env -> Mem -> Maybe (Value, Mem)
evaluateS (SigmaVar v) e mem = case lookup v e of
  Just a  -> Just (a, mem)
  Nothing -> error ("Variable " ++ show v ++ " is undefined!")

evaluateS (Object o) e mem =
  let mc = map (\(l,Method v t) -> (l,Closure e v t)) o
  in Just (ObjRef (length mem), mem ++ [mc])

evaluateS (Call a l) e mem = 
    case evaluateS a e mem of
      Just (ObjRef i,mem') ->
        let ms = mem' !! i
        in case lookup l ms of
              Just (Closure env v m) -> evaluateS m ((v,ObjRef i) : env) mem'
              _ -> error ("Method not found: The method " ++ show l
                          ++ " was not found in:\n" ++ show ms) 
      _ -> error ("Type error: The expression:\n "  ++
                     show a ++ "\n does not evaluate to an object!")

evaluateS (Let x a b) e mem =  --Q2
  let Just (ans, mem') = evaluateS a e mem
      newEnv = (x, ans) : e
      in evaluateS b newEnv mem'

evaluateS (Clone a) e mem = -- Q3
  case evaluateS a e mem of
    Just (ObjRef i, mem') -> -- created an object
      let newObject = access i mem' -- retrieve an object
      in  Just (ObjRef (length mem'), mem' ++ [newObject])
    _ -> error ("Type error: The expression:\n "  ++
                     show a ++ "\n does not evaluate to an object!")

evaluateS (Lit a) e  mem    = Just (VInt a, mem)
evaluateS (Boolean a) e mem = Just (VBool a, mem)                           

evaluateS (Update a l (Method v m)) e mem =
  case evaluateS a e mem of
    Just (ObjRef i, mem') ->
      Just (ObjRef i, replace i l (Closure e v m) mem')

evaluateS (Binary op a b) e mem =  -- Q1
  let Just (v1, mem')  = evaluateS a e mem
      Just (v2, mem'') = evaluateS b e mem'
  in Just (binary op v1 v2, mem'')

evaluateS (Unary op a) e mem = -- Q1
  let Just (v, mem')  = evaluateS a e mem
  in Just (unary op v, mem')

evaluateS (If a b c) e mem = -- Q2
  case evaluateS a e mem of
    Just (VBool test, mem') -> evaluateS (if test then b else c) e mem'
    _                       -> error ("Type error: The expression:\n "  ++
                                      show a ++ "\n does not evaluate to a boolean!")


-- EVALUATE WITH Stateful Monad (Q4)

-- Extending memory by adding obj at the end of the memory
newMemory :: Object -> Stateful Value
newMemory obj = ST (\mem -> (ObjRef (length mem), mem ++ [obj]))

-- Updates memory by accessing object at index i of memory, and updating its method l.
updateMemory :: Int -> Label -> MethodClosure -> Stateful Value
updateMemory i l closure = ST(\mem -> let (before, o : after) = splitAt i mem in
                                      (ObjRef i, before ++ [[if (l == n) then (n, closure) else (n,c) | (n,c) <- o]] ++ after))

-- Replica of access, for accessing memory at index i to retrieve an object.
readMemory :: Int -> Stateful Object
readMemory i = ST (\mem-> (access i mem, mem))


evaluateMonad :: SigmaTerm -> Env -> Stateful Value
evaluateMonad (SigmaVar v) e = case lookup v e of
  Just a  -> return a
  Nothing -> error ("Variable " ++ show v ++ " is undefined!")

evaluateMonad (Object o) e =
  let mc = map (\(l,Method v t) -> (l,Closure e v t)) o in
  newMemory mc

evaluateMonad (Call a l) e = do
  objRef <- evaluateMonad a e
  case objRef of
    ObjRef i -> do
                ms <- readMemory i
                case lookup l ms of
                  Just (Closure env v m) -> evaluateMonad m ((v,ObjRef i) : env)
                  _ -> error ("Method not found: The method " ++ show l
                         ++ " was not found in:\n" ++ show ms) 
    _        -> error ("Type error: The expression:\n "  ++
                     show a ++ "\n does not evaluate to an object!")

evaluateMonad (Let x a b) e = do
  v <- evaluateMonad a e
  let newEnv = (x, v) : e in evaluateMonad b newEnv

evaluateMonad (Clone a) e = do
  objRef <- evaluateMonad a e
  case objRef of
    ObjRef i -> do
                obj <- readMemory i
                newMemory obj
    _        -> error ("Type error: The expression:\n "  ++
                     show a ++ "\n does not evaluate to an object!")

evaluateMonad (Lit a) e     = return (VInt a)
evaluateMonad (Boolean a) e = return (VBool a)                        

evaluateMonad (Update a l (Method v m)) e = do
  objRef <- evaluateMonad a e
  case objRef of
    ObjRef i -> updateMemory i l (Closure e v m)
    _        -> error ("Type error: The expression:\n "  ++
                     show a ++ "\n does not evaluate to an object!")

evaluateMonad (Binary op a b) e = do
  v1 <- evaluateMonad a e
  v2 <- evaluateMonad b e
  return (binary op v1 v2)

evaluateMonad (Unary op a) e = do
  v <- evaluateMonad a e
  return (unary op v)

evaluateMonad (If a b c) e = do
  cond <- evaluateMonad a e
  case cond of
    VBool cond' -> evaluateMonad (if cond' then b else c) e
    _           -> error ("Type error: The expression:\n "  ++
                     show a ++ "\n does not evaluate to a boolean!")


-- EVALUATE BY NEED (ADDITIONAL FEATURE)

-- a function that updates the environment once a value is computed.
updateContext :: String -> Value -> Env -> Env
updateContext _ _ []         = []
updateContext k v (x:xs) = 
  if (show (fst x)) == k 
    then ((Var k, v) : xs) 
    else (x: (updateContext k v xs))

-- See Report.pdf to see the function details
updateEnv :: Env -> Env -> Maybe Int -> Env
updateEnv env1 env2 (Just index) = 
  let (partBefore, o : partAfter) = splitAt (index) env1 in
    partBefore ++ env2 ++ [o] ++ partAfter


evaluateByNeed :: SigmaTerm -> Env -> Mem -> Maybe (Value, Env, Mem)
evaluateByNeed (SigmaVar x) e mem = 
  case lookup x e of
    Just (ClosureX body closureEnv closureMem) -> do
      (v, e', mem') <- evaluateByNeed body closureEnv closureMem
      case v of
        ObjRef i -> Just (ObjRef (i + (length mem)), updateEnv (updateContext (show x) v e) (fst (splitAt ((length e') - 1) e')) (elemIndex x (map(\n -> fst n) e)), mem ++ mem')
        _ -> Just (v, e' ++ (updateContext (show x) v e), mem ++ mem')
    Just a  -> Just (a, e, mem)
    Nothing -> error ("Variable " ++ show x ++ " is undefined!")

evaluateByNeed (Object o) e mem =
  let mc = map (\(l, Method v t) -> (l, Closure e v t)) o
  in Just (ObjRef (length mem), e, mem ++ [mc])

evaluateByNeed (Call a l) e mem = 
    case evaluateByNeed a e mem of
      Just (ObjRef i, _, mem') ->
        let ms = mem' !! i
        in case lookup l ms of
              Just (Closure env v m) -> evaluateByNeed m ((v, ObjRef i) : env) mem'
              _ -> error ("Method not found: The method " ++ show l
                          ++ " was not found in:\n" ++ show ms) 
      _ -> error ("Type error: The expression:\n "  ++
                     show a ++ "\n does not evaluate to an object!")

evaluateByNeed (Let x a b) e mem =  --q2
  let newEnv = (x, ClosureX a e mem) : e
  in evaluateByNeed b newEnv mem

evaluateByNeed (Clone a) e mem = 
  case evaluateByNeed a e mem of
    Just (ObjRef i, e', mem') -> -- created an object
      let newObject = access i mem' -- retrieve an object
      in  Just (ObjRef (length mem'), e', mem' ++ [newObject])
    _ -> error ("Type error: The expression:\n "  ++
                     show a ++ "\n does not evaluate to an object!")

evaluateByNeed (Lit a) e mem     = Just (VInt a, e, mem)
evaluateByNeed (Boolean a) e mem = Just (VBool a, e, mem)                           

evaluateByNeed (Update a l (Method v m)) e mem =
  case evaluateByNeed a e mem of
    Just (ObjRef i, e', mem') ->
      Just (ObjRef i, e', replace i l (Closure e v m) mem')

evaluateByNeed (Binary op a b) e mem =  -- q1
  let Just (v1, e', mem')  = evaluateByNeed a e mem
      Just (v2, e'', mem'') = evaluateByNeed b e' mem'
  in Just (binary op v1 v2, e'', mem'')

evaluateByNeed (Unary op a) e mem = --q1
  let Just (v, e', mem')  = evaluateByNeed a e mem
  in Just (unary op v, e', mem')                       

evaluateByNeed (If a b c) e mem = 
  case evaluateByNeed a e mem of
    Just (VBool test, env, mem') -> evaluateByNeed (if test then b else c) env mem'
    _                            -> error ("Type error: The expression:\n "  ++
                                      show a ++ "\n does not evaluate to a boolean!")


-- Execute functions
execute :: SigmaTerm -> SigmaTerm
execute e = case evaluateS e [] [] of
  Just (ObjRef i, ms) ->  revert (ms !! i)
  Just (VInt i, ms)   -> Lit i
  Just (VBool i, ms)  -> Boolean i
  _                   -> error "Answer is not a value"

executeByNeed :: SigmaTerm -> SigmaTerm
executeByNeed e = case evaluateByNeed e [] [] of
  Just (ObjRef i, env, ms) ->  revert (ms !! i)
  Just (VInt i, env, ms)   -> Lit i
  Just (VBool i, env, ms)  -> Boolean i
  _                        -> error "Answer is not a value"

revert :: Object -> SigmaTerm
revert [] = Object []
revert (x:xs) = let (l, cl) = x in
  case cl of
    Closure _ y s -> let mt = Method y s in
      case revert xs of
        Object ms -> Object ((l, mt):ms)
        _ -> error "Revert function fails"



-- | Tests for Target
--
-- >>> o1 = Object [(Label "l", Method (Var "x")  (Call (SigmaVar (Var "x")) (Label "l")))]
-- >>> o2 = Object [(Label "l", Method (Var "x")  (SigmaVar (Var "x")))]
-- >>> o3 = Object [(Label "l", Method (Var "y")  (Update (SigmaVar (Var "y")) (Label "l") (Method (Var "x") (SigmaVar (Var "x")))))]
-- >>> p1 = Call o1 (Label "l")
-- >>> p2 = Call o2 (Label "l")
-- >>> p3 = Call o3 (Label "l")
-- >>> a2 = execute p2
-- >>> a3 = execute p3
-- >>> a2 == o2
-- True
-- >>> a3 == o2
-- True
-- >>> vtrue = Object [(Label "if", Method (Var "x")  (Call (SigmaVar (Var "x")) (Label "then"))), (Label "then", Method (Var "x")  (Call (SigmaVar (Var "x")) (Label "then"))), (Label "else", Method (Var "x")  (Call (SigmaVar (Var "x")) (Label "else")))]
-- >>> vfalse = Object [(Label "if", Method (Var "x")  (Call (SigmaVar (Var "x")) (Label "else"))), (Label "then", Method (Var "x")  (Call (SigmaVar (Var "x")) (Label "then"))), (Label "else", Method (Var "x")  (Call (SigmaVar (Var "x")) (Label "else")))]
-- >>> cond b c d = Call (Update (Update b (Label "then") (Method (Var "_") c)) (Label "else") (Method (Var "_") d)) (Label "if")
-- >>> if1 = cond vtrue vfalse vtrue
-- >>> (execute if1) == vfalse
-- True
-- >>> if2 = cond vfalse vfalse vtrue
-- >>> (execute if2) == vtrue
-- True


-- Call (Update (Update (Object [(Label "if", Method (Var "x")  (Lit 1)), (Label "then", Method (Var "x") (Lit 3)), (Label "else", Method (Var "x")  (Lit 9))]) (Label "then") (Method (Var "_") (Lit 10))) (Label "else") (Method (Var "_") (Lit -2))) (Label "if")