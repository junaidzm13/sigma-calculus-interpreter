{
module Parser (parseExpr) where
import Data.Char (isDigit, isSpace, isAlpha)
import Prelude hiding (LT, GT, EQ)
import Declare
import Tokens
}


%name parser
%tokentype { Token }
%error { parseError }

%token
    var     { TokenVar }
    vars    { TokenVars }
    and     { TokenAAnd }
    id      { TokenSym $$ }
    label   { TokenSym $$ }
    int     { TokenInt $$ }
    Int     { TokenTInt }
    Bool    { TokenTBool }
    '+'     { TokenPlus }
    '-'     { TokenMinus }
    '*'     { TokenTimes }
    '/'     { TokenDiv }
    '('     { TokenLParen }
    ')'     { TokenRParen }
    '}'     { TokenRB }
    '{'     { TokenLB }
    '['     { TokenLM }
    ']'     { TokenRM }
    ';'     { TokenSemiColon }
    ':'     { TokenColon }
    ','     { TokenComma }
    '.'     { TokenPeriod }
    '='     { TokenEq }
    if      { TokenIf }
    ':='    { TokenAssign }
    else    { TokenElse }
    true    { TokenTrue }
    false   { TokenFalse }
    '<'     { TokenLT }
    '<='    { TokenLE }
    '>'     { TokenGT }
    '>='    { TokenGE }
    '=='    { TokenComp }
    '&&'    { TokenAnd }
    '!'     { TokenNot }
    '||'    { TokenOr }
    fun     { TokenFunc }
    '\\'     { TokenFun }
    '->'    { TokenArrow }
    Lam     { TokenLam }
    Sig     { TokenSig }
    up      { TokenUpdate }
    '<~'    { TokenArrowL }
    class   { TokenClass }
    extends  { TokenInhert }
    top     { TokenTop }
    from    { TokenFrom }
    clone   { TokenClone }
    super   { TokenSuper }
    new     { TokenNew }

%right ';' else
%left '||'
%left '&&'
%nonassoc '=='
%nonassoc '>' '<' '>=' '<='
%left '+' '-'
%left '*' '/'
%left NEG NOT
%right '->'

%monad { Either String }


%%

Exp : var id '=' Exp ';' Exp             { SLet (Var $2) $4 $6 }
    | if '(' Exp ')' Exp ';' else Exp    { SIf $3 $5 $8 }
    | Exp '||' Exp                       { SBin Or $1 $3 }
    | Exp '&&' Exp                       { SBin And $1 $3 }
    | Exp '==' Exp                       { SBin EQ $1 $3 }
    | Exp '<' Exp                        { SBin LT $1 $3 }
    | Exp '>' Exp                        { SBin GT $1 $3 }
    | Exp '<=' Exp                       { SBin LE $1 $3 }
    | Exp '>=' Exp                       { SBin GE $1 $3 }
    | Exp '+' Exp                        { SBin Add $1 $3 }
    | Exp '-' Exp                        { SBin Sub $1 $3 }
    | Exp '*' Exp                        { SBin Mult $1 $3 }
    | Exp '/' Exp                        { SBin Div $1 $3 }
    | '-' Exp %prec NEG                  { SUnary Neg $2 }
    | '!' Exp %prec NOT                  { SUnary Not $2 }
    | '[' Methods ']'                    { SObject $2 }
    | Exp '.' id                        { SCall $1 (Label $3) }
    | Exp '.' id '<~' Method            { SUpdate $1 (Label $3) $5 }
    | '\\'  id '->' Exp                   { Lam (Var $2) $4 }
    | App                                { $1 }
    | clone '(' Exp ')'                  { SClone $3 }
    | SClass                            {  $1 }
    | new Exp                            { SNew $2 }     

SClass : class '{' Methods '}' extends Exp    { Class $3 $6 }
       | class '{' Methods '}'                   { Class $3 Top}

App :  App '(' Exp ')'                   { Apply $1 $3 }
    | int                                { SLit $1 }
    | id                                 { SVar (Var $1) }
    | true                               { SBool True }
    | false                              { SBool False }
    | super                              { SVar (Var "super") }
    | '(' Exp ')'                        { $2 }
    |  Exp '(' Exp ')'                   { Apply $1 $3  }

Method : '{' id '}' Exp                 { SMethod  (Var $2) $4 }
    |  Exp                              { SMethod  (Var "_") $1 }

Methods : id '='  Method              { [(Label $1, $3)] }
    | Methods ',' id '='  Method      { (Label $3, $5):$1 }

{

parseError _ = Left "Parse error"

parseExpr = parser . scanTokens

}
