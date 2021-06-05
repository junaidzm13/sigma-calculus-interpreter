{
module Tokens where
}

%wrapper "basic"

$digit = 0-9
$alpha = [a-zA-Z]

tokens :-

  $white+                       ;
  "--".*                        ;
  var                           { \s -> TokenVar }
  vars                          { \s -> TokenVars }
  and                           { \s -> TokenAAnd }
  if                            { \s -> TokenIf }
  else                          { \s -> TokenElse }
  true                          { \s -> TokenTrue }
  false                         { \s -> TokenFalse }
  $digit+                       { \s -> TokenInt (read s) }
  \;                            { \s -> TokenSemiColon }
  \=                            { \s -> TokenEq }
  \+                            { \s -> TokenPlus }
  \-                            { \s -> TokenMinus }
  \*                            { \s -> TokenTimes }
  \/                            { \s -> TokenDiv }
  \^                            { \s -> TokenPow }
  \<                            { \s -> TokenLT }
  \<\=                          { \s -> TokenLE }
  \>\=                          { \s -> TokenGE }
  \>                            { \s -> TokenGT }
  \=\=                          { \s -> TokenComp }
  \&\&                          { \s -> TokenAnd }
  \|\|                          { \s -> TokenOr }
  \!                            { \s -> TokenNot }
  \(                            { \s -> TokenLParen }
  \)                            { \s -> TokenRParen }
  \{                            { \s -> TokenLB }
  \}                            { \s -> TokenRB }
  \[                            { \s -> TokenLM }
  \]                            { \s -> TokenRM }
  \\                            { \s -> TokenFun }
  \,                            { \s -> TokenComma }
  \:                            { \s -> TokenColon }
  \.                            { \s -> TokenPeriod }
  \:\=                          { \s -> TokenAssign }
  \-\>                          { \s -> TokenArrow }
  \<\~                          { \s -> TokenArrowL }
  fun                           { \s -> TokenFunc }
  Int                           { \s -> TokenTInt }
  Bool                          { \s -> TokenTBool }
  Lam                           { \s -> TokenLam } 
  Sig                           { \s -> TokenSig } 
  up                            { \s -> TokenUpdate }
  class                         { \s -> TokenClass }
  extends                       { \s -> TokenInhert } 
  top                           { \s -> TokenTop } 
  from                          { \s -> TokenFrom }
  clone                         { \s -> TokenClone }
  super                         { \s -> TokenSuper }
  new                           { \s -> TokenNew }
  $alpha [$alpha $digit \_ \']* { \s -> TokenSym s }



{
-- The token type:
data Token = TokenInt Int
           | TokenSym String
           | TokenVar
           | TokenVars
           | TokenAAnd
           | TokenIf
           | TokenElse
           | TokenTrue
           | TokenFalse
           | TokenSemiColon
           | TokenPlus
           | TokenEq
           | TokenPeriod
           | TokenMinus
           | TokenTimes
           | TokenDiv
           | TokenPow
           | TokenLT
           | TokenLE
           | TokenGT
           | TokenGE
           | TokenComp
           | TokenAnd
           | TokenOr
           | TokenNot
           | TokenLParen
           | TokenRParen
           | TokenLB
           | TokenRB
           | TokenLM
           | TokenRM
           | TokenAssign
           | TokenComma
           | TokenColon
           | TokenFunc
           | TokenTInt
           | TokenTBool
           | TokenArrow
           | TokenArrowL
           | TokenLam
           | TokenSig
           | TokenUpdate
           | TokenClass
           | TokenInhert
           | TokenTop
           | TokenFrom
           | TokenFun
           | TokenClone
           | TokenSuper
           | TokenNew
           deriving (Eq,Show)

scanTokens = alexScanTokens
}
