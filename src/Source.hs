module Source where

import Parser
import Declare
import Target
import Data.List

type TClass = [(Var, Exp)]

-- Q5
-- Substitue function that follows the substitute functioning as described in the project file.
substitute1 :: SigmaTerm -> Var -> SigmaTerm -> SigmaTerm
substitute1 (Binary op e1 e2) var call               = Binary op (substitute1 e1 var call) (substitute1 e2 var call)
substitute1 (Unary op e) var call                    = Unary op (substitute1 e var call)
substitute1 (If a b c) var call                      = If (substitute1 a var call) (substitute1 b var call) (substitute1 c var call)
substitute1 (Clone a) var call                       = Clone (substitute1 a var call)
substitute1 (Let v exp body) var call                = Let v (substitute1 exp var call) (substitute1 body var call)
substitute1 (Update exp1 l (Method v exp2)) var call = Update (substitute1 exp1 var call) l (Method v (substitute1 exp2 var call))
substitute1 (Call exp l) var call                    = Call (substitute1 exp var call) l
substitute1 (Object l) var call                      = Object [(v, Method arg (substitute1 sigmaTerm var call)) | (v, Method arg sigmaTerm) <- l]
substitute1 (SigmaVar v) var call                    = if v == var then call else SigmaVar v
substitute1 st var call                              = st

-- Helper for translate - translates each Exp to SigmaTerm
transHelp :: Exp -> TClass -> Int -> SigmaTerm
transHelp (SLit a) _ xs         = Lit a
transHelp (SBool b) _ xs        = Boolean b
transHelp (SUnary op e) tc xs   = Unary op (transHelp e tc xs)
transHelp (SBin op e1 e2) tc xs = Binary op (transHelp e1 tc xs) (transHelp e2 tc xs)
transHelp (SIf e1 e2 e3) tc xs  = If (transHelp e1 tc xs) (transHelp e2 tc xs) (transHelp e3 tc xs)
transHelp (SVar v) _ xs         = SigmaVar v
transHelp (SClone e) tc xs      = Clone (transHelp e tc xs)
transHelp (SObject x) tc xs     = Object [ (l, Method v (transHelp exp tc (xs + 1))) | (l, SMethod v exp) <- x]   
transHelp (SCall e l) tc xs     = Call (transHelp e tc xs) l
transHelp (SLet v e1 e2) tc xs  =
  case e1 of
    Class _ _ -> let tc' = (v, e1) : tc in transHelp e2 tc' xs
    _         -> Let v (transHelp e1 tc xs) (transHelp e2 tc xs)
transHelp (Lam x body) tc xs    = 
  Object [
    (Label "arg", Method (Var (show xs ++ "*")) (Call (SigmaVar (Var (show xs ++ "*"))) (Label "arg"))), 
    (Label "val", Method (Var (show xs ++ "*")) (substitute1 (transHelp body tc (xs + 1)) x (Call (SigmaVar (Var (show xs ++ "*"))) (Label "arg"))))
  ]
transHelp (Apply e1 e2) tc xs   = 
  Let (Var "f") (Clone (transHelp e1 tc xs)) (Let (Var "y") (transHelp e2 tc xs) (Call (Update (SigmaVar (Var "f")) (Label "arg") (Method (Var "@") (SigmaVar (Var "y")))) (Label "val")))
transHelp (SNew a) tc xs        = Call (transHelp (classGen a tc) tc xs) (Label "new")
transHelp (SUpdate e l (SMethod v exp)) tc xs = Update (transHelp e tc xs) l (Method v (transHelp exp tc xs))

translate :: Exp -> TClass -> SigmaTerm
translate exp tc = transHelp exp tc 0


-- Q6 and Q7
-- See Report.pdf for explanations of these functions
doItSuper :: (Label, SMethod) -> [(Label, SMethod)] -> (Label, SMethod)
doItSuper (l, SMethod objRef body) parentCObject = 
  case body of
    SCall (SVar (Var "super")) methodLabel -> case lookup methodLabel parentCObject of
                                                Just (SMethod vO expO) -> (l, SMethod objRef (Apply expO (SVar vO))) 
    Apply (SCall (SVar (Var "super")) methodLabel) arg -> case lookup methodLabel parentCObject of
                                                                Just (SMethod vO expO) -> (l, SMethod objRef (Apply expO arg))
    _ -> (l, SMethod objRef body)


checkClass ::  [(Label, SMethod)] -> (Label, SMethod) -> Bool
checkClass [] (label, method) = True
checkClass ((l,s):xs) (label, method) = 
  if l == label then False else checkClass xs (label, method) 


-- exp passed could either be a variable or a class object
classGen :: Exp -> TClass -> Exp
classGen (Class cMethods exp) tc = -- Case when we have a Class expression directly
  case exp of
    Class cT expT -> -- Case when the class extends another Class
      case classGen (Class cT expT) [] of
        SObject cMethsTemp ->
          let c2    = [(Label l, m) | (Label l, m) <- cMethsTemp, l /= "new"] in
          let cNew  = map (\n -> doItSuper n cMethsTemp) cMethods in
          let listD = filter(\label -> checkClass cMethods label) c2 in
          let newL  = cNew ++ listD  in
          let list  = SObject [(label, SMethod var (Apply (SCall (SVar (Var "z")) label) (SVar var) )) | (label, SMethod var exp) <- newL] in
          let listC = [ (Label "new",  SMethod (Var "z") list)] in  
          SObject (listC ++ [(label, SMethod var (Lam var exp)) | (label, SMethod var exp) <- cNew] ++ [(label, SMethod var (SCall (SObject c2) (label))) | (label, SMethod var _) <- listD])
        
    SVar v -> -- Case when the class extends another class which is referenced by a varibale SVar v
      case lookup v tc of
        Just classExp -> classGen (Class cMethods classExp) tc
        
    _ -> -- Top case - when the class does not extend any other class
      let list  = SObject [(label, SMethod var (Apply (SCall (SVar (Var "z")) label) (SVar var) )) | (label, SMethod var _) <- cMethods] in
      let listC = [(Label "new",  SMethod (Var "z") list)] in
      SObject (listC ++ [(label, SMethod var (Lam var exp)) | (label, SMethod var exp) <- cMethods])

classGen (SVar var) tc = -- Case when the Class is referenced by a variable SVar var
  case lookup var tc of
    Just exp -> classGen exp tc
    Nothing  -> error ("Class " ++ show var ++ " not found in TClass!")