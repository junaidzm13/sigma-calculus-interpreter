{-# OPTIONS_GHC -w #-}
{-# OPTIONS -XMagicHash -XBangPatterns -XTypeSynonymInstances -XFlexibleInstances -cpp #-}
#if __GLASGOW_HASKELL__ >= 710
{-# OPTIONS_GHC -XPartialTypeSignatures #-}
#endif
module Parser (parseExpr) where
import Data.Char (isDigit, isSpace, isAlpha)
import Prelude hiding (LT, GT, EQ)
import Declare
import Tokens
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import qualified GHC.Exts as Happy_GHC_Exts
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.20.0

newtype HappyAbsSyn t4 t5 t6 t7 t8 = HappyAbsSyn HappyAny
#if __GLASGOW_HASKELL__ >= 607
type HappyAny = Happy_GHC_Exts.Any
#else
type HappyAny = forall a . a
#endif
happyIn4 :: t4 -> (HappyAbsSyn t4 t5 t6 t7 t8)
happyIn4 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn4 #-}
happyOut4 :: (HappyAbsSyn t4 t5 t6 t7 t8) -> t4
happyOut4 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut4 #-}
happyIn5 :: t5 -> (HappyAbsSyn t4 t5 t6 t7 t8)
happyIn5 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn5 #-}
happyOut5 :: (HappyAbsSyn t4 t5 t6 t7 t8) -> t5
happyOut5 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut5 #-}
happyIn6 :: t6 -> (HappyAbsSyn t4 t5 t6 t7 t8)
happyIn6 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn6 #-}
happyOut6 :: (HappyAbsSyn t4 t5 t6 t7 t8) -> t6
happyOut6 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut6 #-}
happyIn7 :: t7 -> (HappyAbsSyn t4 t5 t6 t7 t8)
happyIn7 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn7 #-}
happyOut7 :: (HappyAbsSyn t4 t5 t6 t7 t8) -> t7
happyOut7 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut7 #-}
happyIn8 :: t8 -> (HappyAbsSyn t4 t5 t6 t7 t8)
happyIn8 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn8 #-}
happyOut8 :: (HappyAbsSyn t4 t5 t6 t7 t8) -> t8
happyOut8 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut8 #-}
happyInTok :: (Token) -> (HappyAbsSyn t4 t5 t6 t7 t8)
happyInTok x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyInTok #-}
happyOutTok :: (HappyAbsSyn t4 t5 t6 t7 t8) -> (Token)
happyOutTok x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOutTok #-}


happyExpList :: HappyAddr
happyExpList = HappyA# "\x00\x29\x12\x81\x0c\x24\x88\x03\x08\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x3e\x40\xe0\x17\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x29\x12\x81\x0c\x24\x88\x03\x48\x91\x08\x64\x20\x41\x1c\x00\x02\x00\x00\x00\x00\x00\x00\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xa4\x48\x04\x32\x90\x20\x0e\x00\x01\x00\x00\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x52\x24\x02\x19\x48\x10\x07\x00\x00\x00\x00\x00\x00\x00\x80\x14\x89\x40\x06\x12\xc4\x01\x20\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00\x48\x91\x08\x64\x20\x41\x1c\x00\x00\x80\x04\x00\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00\xf0\x03\x02\xbf\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xa4\x48\x04\x32\x90\x20\x0e\x20\x45\x22\x90\x81\x04\x71\x00\x29\x12\x81\x0c\x24\x88\x03\x48\x91\x08\x64\x20\x41\x1c\x40\x8a\x44\x20\x03\x09\xe2\x00\x52\x24\x02\x19\x48\x10\x07\x80\x00\x00\x00\x00\x00\x00\x80\x14\x89\x40\x06\x12\xc4\x01\xa4\x48\x04\x32\x90\x20\x0e\x20\x45\x22\x90\x81\x04\x71\x00\x29\x12\x81\x0c\x24\x88\x03\x48\x91\x08\x64\x20\x41\x1c\x40\x8a\x44\x20\x03\x09\xe2\x00\x52\x24\x02\x19\x48\x10\x07\x00\x00\x00\x04\x00\x00\x00\x80\x14\x89\x40\x06\x12\xc4\x01\x00\x3c\x00\xc0\x0f\x00\x00\x00\xe0\x01\x00\x3e\x00\x00\x00\x00\x0f\x00\xf0\x00\x00\x00\x00\x78\x00\x00\x00\x00\x00\x00\xc0\x03\x00\x00\x00\x00\x00\x00\x1e\x00\x00\x00\x00\x00\x00\xf0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\xfc\x80\xc0\x2f\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x60\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x7e\x40\xe0\x17\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80\x14\xc9\x40\x06\x12\xc4\x01\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x3f\x20\xf0\x0b\x00\x00\x48\x91\x08\x64\x20\x41\x1c\x00\x00\x10\x04\x00\x00\x00\x00\x00\x7e\x40\xe0\x17\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x00\x20\x45\x22\x90\x81\x04\x71\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xa4\x48\x06\x32\x90\x20\x0e\x00\xe0\x83\x04\x7e\x01\x00\x00\x29\x12\x81\x0c\x24\x88\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x52\x24\x03\x19\x48\x10\x07\x00\xf0\x41\x02\xbf\x00\x00\x80\x14\x89\x40\x06\x12\xc4\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x48\x91\x08\x64\x20\x41\x1c\x00\xc0\x03\x00\xfc\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x90\x22\x11\xc8\x40\x82\x38\x00\x80\x07\x00\xf8\x05\x00\x00\x00\x00"#

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_parser","Exp","SClass","App","Method","Methods","var","vars","and","id","label","int","Int","Bool","'+'","'-'","'*'","'/'","'('","')'","'}'","'{'","'['","']'","';'","':'","','","'.'","'='","if","':='","else","true","false","'<'","'<='","'>'","'>='","'=='","'&&'","'!'","'||'","fun","'\\\\'","'->'","Lam","Sig","up","'<~'","class","extends","top","from","clone","super","new","%eof"]
        bit_start = st Prelude.* 59
        bit_end = (st Prelude.+ 1) Prelude.* 59
        read_bit = readArrayBit happyExpList
        bits = Prelude.map read_bit [bit_start..bit_end Prelude.- 1]
        bits_indexed = Prelude.zip bits [0..58]
        token_strs_expected = Prelude.concatMap f bits_indexed
        f (Prelude.False, _) = []
        f (Prelude.True, nr) = [token_strs Prelude.!! nr]

happyActOffsets :: HappyAddr
happyActOffsets = HappyA# "\x14\x00\x05\x00\x09\x00\x32\x00\x00\x00\x02\x00\x00\x00\x00\x00\x14\x00\x14\x00\x0c\x00\x07\x00\x00\x00\x00\x00\x14\x00\x12\x00\x0b\x00\x0a\x00\x00\x00\x14\x00\x05\x01\x14\x00\x1b\x00\xfb\xff\xf6\xff\x14\x00\xef\xff\x17\x00\x4e\x00\xf6\xff\x14\x00\x14\x00\x14\x00\x14\x00\x14\x00\x14\x00\x1f\x00\x14\x00\x14\x00\x14\x00\x14\x00\x14\x00\x14\x00\x14\x00\x21\x00\x14\x00\x14\x01\x22\x01\x30\x01\x3e\x01\x3e\x01\x3e\x01\x3e\x01\x0e\x00\x6a\x00\xf6\xff\xf6\xff\xfd\xff\xfd\xff\x86\x00\x00\x00\x01\x00\x00\x00\x43\x00\xa2\x00\x14\x00\x11\x00\xbe\x00\x00\x00\x20\x00\xf6\xff\x14\x00\x37\x00\x05\x01\x00\x00\x51\x00\x00\x00\x00\x00\x01\x00\xda\x00\x14\x00\x00\x00\x5a\x00\x01\x00\xf6\x00\x14\x00\x05\x01\x50\x00\x00\x00\x14\x00\x05\x01\x05\x01\x14\x00\x05\x01\x00\x00"#

happyGotoOffsets :: HappyAddr
happyGotoOffsets = HappyA# "\x34\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x41\x00\x61\x00\x6d\x00\x00\x00\x00\x00\x00\x00\x66\x00\x00\x00\x00\x00\x00\x00\x00\x00\x79\x00\x00\x00\x7c\x00\x7b\x00\x00\x00\x00\x00\x81\x00\x00\x00\x00\x00\x00\x00\x00\x00\x84\x00\x95\x00\x98\x00\x9d\x00\xa0\x00\xb1\x00\x00\x00\xb4\x00\xb9\x00\xbc\x00\xcd\x00\xd0\x00\xd5\x00\xd8\x00\x00\x00\xe8\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x28\x00\x00\x00\x00\x00\x00\x00\xf1\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xf4\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x49\x00\x00\x00\x04\x01\x00\x00\x00\x00\x5d\x00\x00\x00\x55\x01\x00\x00\x00\x00\x00\x00\x58\x01\x00\x00\x00\x00\x5f\x01\x00\x00\x00\x00"#

happyAdjustOffset :: Happy_GHC_Exts.Int# -> Happy_GHC_Exts.Int#
happyAdjustOffset off = off

happyDefActions :: HappyAddr
happyDefActions = HappyA# "\x00\x00\x00\x00\x00\x00\x00\x00\xe9\xff\xeb\xff\xe3\xff\xe4\xff\x00\x00\x00\x00\x00\x00\x00\x00\xe2\xff\xe1\xff\x00\x00\x00\x00\x00\x00\x00\x00\xe0\xff\x00\x00\xe8\xff\x00\x00\x00\x00\x00\x00\xf0\xff\x00\x00\x00\x00\x00\x00\x00\x00\xf1\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xfc\xff\xfb\xff\xfa\xff\xf6\xff\xf8\xff\xf7\xff\xf9\xff\xee\xff\x00\x00\xf2\xff\xf3\xff\xf4\xff\xf5\xff\x00\x00\xdf\xff\x00\x00\xef\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xea\xff\xe6\xff\xec\xff\x00\x00\x00\x00\xdc\xff\xdb\xff\x00\x00\xe5\xff\xde\xff\x00\x00\x00\x00\x00\x00\xed\xff\x00\x00\x00\x00\x00\x00\x00\x00\xe7\xff\x00\x00\xda\xff\x00\x00\xfe\xff\xdd\xff\x00\x00\xfd\xff"#

happyCheck :: HappyAddr
happyCheck = HappyA# "\xff\xff\x12\x00\x01\x00\x0d\x00\x15\x00\x04\x00\x01\x00\x06\x00\x0b\x00\x0c\x00\x0d\x00\x0a\x00\x16\x00\x04\x00\x0d\x00\x0d\x00\x04\x00\x10\x00\x11\x00\x16\x00\x0d\x00\x01\x00\x04\x00\x0d\x00\x04\x00\x18\x00\x06\x00\x10\x00\x1b\x00\x1c\x00\x0a\x00\x04\x00\x0f\x00\x0d\x00\x27\x00\x04\x00\x23\x00\x11\x00\x15\x00\x26\x00\x00\x00\x01\x00\x02\x00\x03\x00\x18\x00\x2c\x00\x17\x00\x1b\x00\x1c\x00\x30\x00\x31\x00\x32\x00\x00\x00\x01\x00\x02\x00\x23\x00\x17\x00\x2b\x00\x26\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x2c\x00\x00\x00\x01\x00\x02\x00\x30\x00\x31\x00\x32\x00\x04\x00\x16\x00\x00\x00\x01\x00\x02\x00\x03\x00\x2d\x00\x17\x00\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\x22\x00\x04\x00\x24\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x0e\x00\x00\x00\x01\x00\x02\x00\x03\x00\x00\x00\x01\x00\x02\x00\x16\x00\x33\x00\x00\x00\x01\x00\x02\x00\x0f\x00\x1a\x00\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\x22\x00\x04\x00\x24\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x0e\x00\x00\x00\x01\x00\x02\x00\x00\x00\x01\x00\x02\x00\x04\x00\x16\x00\x00\x00\x01\x00\x02\x00\x00\x00\x01\x00\x02\x00\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\x22\x00\xff\xff\x24\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x0e\x00\x00\x00\x01\x00\x02\x00\x00\x00\x01\x00\x02\x00\xff\xff\x16\x00\x00\x00\x01\x00\x02\x00\x00\x00\x01\x00\x02\x00\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\x22\x00\xff\xff\x24\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x0e\x00\x00\x00\x01\x00\x02\x00\x00\x00\x01\x00\x02\x00\xff\xff\x16\x00\x00\x00\x01\x00\x02\x00\x00\x00\x01\x00\x02\x00\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\x22\x00\xff\xff\x24\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x0e\x00\x00\x00\x01\x00\x02\x00\x00\x00\x01\x00\x02\x00\xff\xff\x16\x00\x00\x00\x01\x00\x02\x00\x00\x00\x01\x00\x02\x00\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\x22\x00\xff\xff\x24\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x00\x00\x01\x00\x02\x00\xff\xff\xff\xff\x13\x00\xff\xff\xff\xff\x16\x00\x00\x00\x01\x00\x02\x00\x00\x00\x01\x00\x02\x00\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\x22\x00\xff\xff\x24\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x00\x00\x01\x00\x02\x00\xff\xff\xff\xff\x13\x00\xff\xff\xff\xff\x16\x00\xff\xff\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\x22\x00\xff\xff\x24\x00\x16\x00\xff\xff\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\x22\x00\xff\xff\x24\x00\x16\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\xff\xff\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\x22\x00\xff\xff\x16\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\xff\xff\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\xff\xff\xff\xff\x16\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\xff\xff\x1d\x00\x1e\x00\x1f\x00\x20\x00\x21\x00\xff\xff\xff\xff\x16\x00\x00\x00\x01\x00\x02\x00\x00\x00\x01\x00\x02\x00\x1d\x00\x1e\x00\x1f\x00\x20\x00\x00\x00\x01\x00\x02\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"#

happyTable :: HappyAddr
happyTable = HappyA# "\x00\x00\x3f\x00\x03\x00\x24\x00\x40\x00\x07\x00\x03\x00\x08\x00\x22\x00\x23\x00\x24\x00\x09\x00\x25\x00\x2d\x00\x0a\x00\x1f\x00\x1c\x00\x4c\x00\x0b\x00\x25\x00\x1a\x00\x03\x00\x18\x00\x16\x00\x07\x00\x0c\x00\x08\x00\x17\x00\x0d\x00\x0e\x00\x09\x00\x1c\x00\x46\x00\x0a\x00\x42\x00\x36\x00\x0f\x00\x0b\x00\x40\x00\x10\x00\x49\x00\x04\x00\x05\x00\x4a\x00\x0c\x00\x11\x00\x3e\x00\x0d\x00\x0e\x00\x12\x00\x13\x00\x14\x00\x03\x00\x04\x00\x05\x00\x0f\x00\x2e\x00\x4f\x00\x10\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x11\x00\x1d\x00\x04\x00\x05\x00\x12\x00\x13\x00\x14\x00\x49\x00\x25\x00\x49\x00\x04\x00\x05\x00\x51\x00\x56\x00\x54\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x53\x00\x2c\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x3d\x00\x49\x00\x04\x00\x05\x00\x58\x00\x1c\x00\x04\x00\x05\x00\x25\x00\xff\xff\x18\x00\x04\x00\x05\x00\x5a\x00\x5d\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x1a\x00\x2c\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x4e\x00\x14\x00\x04\x00\x05\x00\x43\x00\x04\x00\x05\x00\x42\x00\x25\x00\x40\x00\x04\x00\x05\x00\x3b\x00\x04\x00\x05\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x00\x00\x2c\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x4d\x00\x3a\x00\x04\x00\x05\x00\x39\x00\x04\x00\x05\x00\x00\x00\x25\x00\x38\x00\x04\x00\x05\x00\x37\x00\x04\x00\x05\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x00\x00\x2c\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x48\x00\x36\x00\x04\x00\x05\x00\x34\x00\x04\x00\x05\x00\x00\x00\x25\x00\x33\x00\x04\x00\x05\x00\x32\x00\x04\x00\x05\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x00\x00\x2c\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x45\x00\x31\x00\x04\x00\x05\x00\x30\x00\x04\x00\x05\x00\x00\x00\x25\x00\x2f\x00\x04\x00\x05\x00\x2e\x00\x04\x00\x05\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x00\x00\x2c\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x4f\x00\x04\x00\x05\x00\x00\x00\x00\x00\x51\x00\x00\x00\x00\x00\x25\x00\x46\x00\x04\x00\x05\x00\x54\x00\x04\x00\x05\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x00\x00\x2c\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x5a\x00\x04\x00\x05\x00\x00\x00\x00\x00\x58\x00\x00\x00\x00\x00\x25\x00\x00\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x00\x00\x2c\x00\x25\x00\x00\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x00\x00\x2c\x00\x25\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x00\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x00\x00\x25\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x00\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x00\x00\x00\x00\x25\x00\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x00\x00\x26\x00\x27\x00\x28\x00\x29\x00\x00\x00\x00\x00\x00\x00\x25\x00\x56\x00\x04\x00\x05\x00\x5b\x00\x04\x00\x05\x00\x00\x00\x00\x00\x00\x00\x00\x00\x5d\x00\x04\x00\x05\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"#

happyReduceArr = Happy_Data_Array.array (1, 37) [
	(1 , happyReduce_1),
	(2 , happyReduce_2),
	(3 , happyReduce_3),
	(4 , happyReduce_4),
	(5 , happyReduce_5),
	(6 , happyReduce_6),
	(7 , happyReduce_7),
	(8 , happyReduce_8),
	(9 , happyReduce_9),
	(10 , happyReduce_10),
	(11 , happyReduce_11),
	(12 , happyReduce_12),
	(13 , happyReduce_13),
	(14 , happyReduce_14),
	(15 , happyReduce_15),
	(16 , happyReduce_16),
	(17 , happyReduce_17),
	(18 , happyReduce_18),
	(19 , happyReduce_19),
	(20 , happyReduce_20),
	(21 , happyReduce_21),
	(22 , happyReduce_22),
	(23 , happyReduce_23),
	(24 , happyReduce_24),
	(25 , happyReduce_25),
	(26 , happyReduce_26),
	(27 , happyReduce_27),
	(28 , happyReduce_28),
	(29 , happyReduce_29),
	(30 , happyReduce_30),
	(31 , happyReduce_31),
	(32 , happyReduce_32),
	(33 , happyReduce_33),
	(34 , happyReduce_34),
	(35 , happyReduce_35),
	(36 , happyReduce_36),
	(37 , happyReduce_37)
	]

happy_n_terms = 52 :: Prelude.Int
happy_n_nonterms = 5 :: Prelude.Int

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_1 = happyReduce 6# 0# happyReduction_1
happyReduction_1 (happy_x_6 `HappyStk`
	happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOutTok happy_x_2 of { (TokenSym happy_var_2) -> 
	case happyOut4 happy_x_4 of { happy_var_4 -> 
	case happyOut4 happy_x_6 of { happy_var_6 -> 
	happyIn4
		 (SLet (Var happy_var_2) happy_var_4 happy_var_6
	) `HappyStk` happyRest}}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_2 = happyReduce 8# 0# happyReduction_2
happyReduction_2 (happy_x_8 `HappyStk`
	happy_x_7 `HappyStk`
	happy_x_6 `HappyStk`
	happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut4 happy_x_3 of { happy_var_3 -> 
	case happyOut4 happy_x_5 of { happy_var_5 -> 
	case happyOut4 happy_x_8 of { happy_var_8 -> 
	happyIn4
		 (SIf happy_var_3 happy_var_5 happy_var_8
	) `HappyStk` happyRest}}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_3 = happySpecReduce_3  0# happyReduction_3
happyReduction_3 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SBin Or happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_4 = happySpecReduce_3  0# happyReduction_4
happyReduction_4 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SBin And happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_5 = happySpecReduce_3  0# happyReduction_5
happyReduction_5 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SBin EQ happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_6 = happySpecReduce_3  0# happyReduction_6
happyReduction_6 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SBin LT happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_7 = happySpecReduce_3  0# happyReduction_7
happyReduction_7 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SBin GT happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_8 = happySpecReduce_3  0# happyReduction_8
happyReduction_8 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SBin LE happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_9 = happySpecReduce_3  0# happyReduction_9
happyReduction_9 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SBin GE happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_10 = happySpecReduce_3  0# happyReduction_10
happyReduction_10 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SBin Add happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_11 = happySpecReduce_3  0# happyReduction_11
happyReduction_11 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SBin Sub happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_12 = happySpecReduce_3  0# happyReduction_12
happyReduction_12 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SBin Mult happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_13 = happySpecReduce_3  0# happyReduction_13
happyReduction_13 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SBin Div happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_14 = happySpecReduce_2  0# happyReduction_14
happyReduction_14 happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_2 of { happy_var_2 -> 
	happyIn4
		 (SUnary Neg happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_15 = happySpecReduce_2  0# happyReduction_15
happyReduction_15 happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_2 of { happy_var_2 -> 
	happyIn4
		 (SUnary Not happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_16 = happySpecReduce_3  0# happyReduction_16
happyReduction_16 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut8 happy_x_2 of { happy_var_2 -> 
	happyIn4
		 (SObject happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_17 = happySpecReduce_3  0# happyReduction_17
happyReduction_17 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOutTok happy_x_3 of { (TokenSym happy_var_3) -> 
	happyIn4
		 (SCall happy_var_1 (Label happy_var_3)
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_18 = happyReduce 5# 0# happyReduction_18
happyReduction_18 (happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOutTok happy_x_3 of { (TokenSym happy_var_3) -> 
	case happyOut7 happy_x_5 of { happy_var_5 -> 
	happyIn4
		 (SUpdate happy_var_1 (Label happy_var_3) happy_var_5
	) `HappyStk` happyRest}}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_19 = happyReduce 4# 0# happyReduction_19
happyReduction_19 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOutTok happy_x_2 of { (TokenSym happy_var_2) -> 
	case happyOut4 happy_x_4 of { happy_var_4 -> 
	happyIn4
		 (Lam (Var happy_var_2) happy_var_4
	) `HappyStk` happyRest}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_20 = happySpecReduce_1  0# happyReduction_20
happyReduction_20 happy_x_1
	 =  case happyOut6 happy_x_1 of { happy_var_1 -> 
	happyIn4
		 (happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_21 = happyReduce 4# 0# happyReduction_21
happyReduction_21 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn4
		 (SClone happy_var_3
	) `HappyStk` happyRest}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_22 = happySpecReduce_1  0# happyReduction_22
happyReduction_22 happy_x_1
	 =  case happyOut5 happy_x_1 of { happy_var_1 -> 
	happyIn4
		 (happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_23 = happySpecReduce_2  0# happyReduction_23
happyReduction_23 happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_2 of { happy_var_2 -> 
	happyIn4
		 (SNew happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_24 = happyReduce 6# 1# happyReduction_24
happyReduction_24 (happy_x_6 `HappyStk`
	happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut8 happy_x_3 of { happy_var_3 -> 
	case happyOut4 happy_x_6 of { happy_var_6 -> 
	happyIn5
		 (Class happy_var_3 happy_var_6
	) `HappyStk` happyRest}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_25 = happyReduce 4# 1# happyReduction_25
happyReduction_25 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut8 happy_x_3 of { happy_var_3 -> 
	happyIn5
		 (Class happy_var_3 Top
	) `HappyStk` happyRest}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_26 = happyReduce 4# 2# happyReduction_26
happyReduction_26 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut6 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn6
		 (Apply happy_var_1 happy_var_3
	) `HappyStk` happyRest}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_27 = happySpecReduce_1  2# happyReduction_27
happyReduction_27 happy_x_1
	 =  case happyOutTok happy_x_1 of { (TokenInt happy_var_1) -> 
	happyIn6
		 (SLit happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_28 = happySpecReduce_1  2# happyReduction_28
happyReduction_28 happy_x_1
	 =  case happyOutTok happy_x_1 of { (TokenSym happy_var_1) -> 
	happyIn6
		 (SVar (Var happy_var_1)
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_29 = happySpecReduce_1  2# happyReduction_29
happyReduction_29 happy_x_1
	 =  happyIn6
		 (SBool True
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_30 = happySpecReduce_1  2# happyReduction_30
happyReduction_30 happy_x_1
	 =  happyIn6
		 (SBool False
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_31 = happySpecReduce_1  2# happyReduction_31
happyReduction_31 happy_x_1
	 =  happyIn6
		 (SVar (Var "super")
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_32 = happySpecReduce_3  2# happyReduction_32
happyReduction_32 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_2 of { happy_var_2 -> 
	happyIn6
		 (happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_33 = happyReduce 4# 2# happyReduction_33
happyReduction_33 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut4 happy_x_3 of { happy_var_3 -> 
	happyIn6
		 (Apply happy_var_1 happy_var_3
	) `HappyStk` happyRest}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_34 = happyReduce 4# 3# happyReduction_34
happyReduction_34 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOutTok happy_x_2 of { (TokenSym happy_var_2) -> 
	case happyOut4 happy_x_4 of { happy_var_4 -> 
	happyIn7
		 (SMethod  (Var happy_var_2) happy_var_4
	) `HappyStk` happyRest}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_35 = happySpecReduce_1  3# happyReduction_35
happyReduction_35 happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	happyIn7
		 (SMethod  (Var "_") happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_36 = happySpecReduce_3  4# happyReduction_36
happyReduction_36 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOutTok happy_x_1 of { (TokenSym happy_var_1) -> 
	case happyOut7 happy_x_3 of { happy_var_3 -> 
	happyIn8
		 ([(Label happy_var_1, happy_var_3)]
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_37 = happyReduce 5# 4# happyReduction_37
happyReduction_37 (happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut8 happy_x_1 of { happy_var_1 -> 
	case happyOutTok happy_x_3 of { (TokenSym happy_var_3) -> 
	case happyOut7 happy_x_5 of { happy_var_5 -> 
	happyIn8
		 ((Label happy_var_3, happy_var_5):happy_var_1
	) `HappyStk` happyRest}}}

happyNewToken action sts stk [] =
	happyDoAction 51# notHappyAtAll action sts stk []

happyNewToken action sts stk (tk:tks) =
	let cont i = happyDoAction i tk action sts stk tks in
	case tk of {
	TokenVar -> cont 1#;
	TokenVars -> cont 2#;
	TokenAAnd -> cont 3#;
	TokenSym happy_dollar_dollar -> cont 4#;
	TokenSym happy_dollar_dollar -> cont 5#;
	TokenInt happy_dollar_dollar -> cont 6#;
	TokenTInt -> cont 7#;
	TokenTBool -> cont 8#;
	TokenPlus -> cont 9#;
	TokenMinus -> cont 10#;
	TokenTimes -> cont 11#;
	TokenDiv -> cont 12#;
	TokenLParen -> cont 13#;
	TokenRParen -> cont 14#;
	TokenRB -> cont 15#;
	TokenLB -> cont 16#;
	TokenLM -> cont 17#;
	TokenRM -> cont 18#;
	TokenSemiColon -> cont 19#;
	TokenColon -> cont 20#;
	TokenComma -> cont 21#;
	TokenPeriod -> cont 22#;
	TokenEq -> cont 23#;
	TokenIf -> cont 24#;
	TokenAssign -> cont 25#;
	TokenElse -> cont 26#;
	TokenTrue -> cont 27#;
	TokenFalse -> cont 28#;
	TokenLT -> cont 29#;
	TokenLE -> cont 30#;
	TokenGT -> cont 31#;
	TokenGE -> cont 32#;
	TokenComp -> cont 33#;
	TokenAnd -> cont 34#;
	TokenNot -> cont 35#;
	TokenOr -> cont 36#;
	TokenFunc -> cont 37#;
	TokenFun -> cont 38#;
	TokenArrow -> cont 39#;
	TokenLam -> cont 40#;
	TokenSig -> cont 41#;
	TokenUpdate -> cont 42#;
	TokenArrowL -> cont 43#;
	TokenClass -> cont 44#;
	TokenInhert -> cont 45#;
	TokenTop -> cont 46#;
	TokenFrom -> cont 47#;
	TokenClone -> cont 48#;
	TokenSuper -> cont 49#;
	TokenNew -> cont 50#;
	_ -> happyError' ((tk:tks), [])
	}

happyError_ explist 51# tk tks = happyError' (tks, explist)
happyError_ explist _ tk tks = happyError' ((tk:tks), explist)

happyThen :: () => Either String a -> (a -> Either String b) -> Either String b
happyThen = (Prelude.>>=)
happyReturn :: () => a -> Either String a
happyReturn = (Prelude.return)
happyThen1 m k tks = (Prelude.>>=) m (\a -> k a tks)
happyReturn1 :: () => a -> b -> Either String a
happyReturn1 = \a tks -> (Prelude.return) a
happyError' :: () => ([(Token)], [Prelude.String]) -> Either String a
happyError' = (\(tokens, _) -> parseError tokens)
parser tks = happySomeParser where
 happySomeParser = happyThen (happyParse 0# tks) (\x -> happyReturn (let {x' = happyOut4 x} in x'))

happySeq = happyDontSeq


parseError _ = Left "Parse error"

parseExpr = parser . scanTokens
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- $Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp $













-- Do not remove this comment. Required to fix CPP parsing when using GCC and a clang-compiled alex.
#if __GLASGOW_HASKELL__ > 706
#define LT(n,m) ((Happy_GHC_Exts.tagToEnum# (n Happy_GHC_Exts.<# m)) :: Prelude.Bool)
#define GTE(n,m) ((Happy_GHC_Exts.tagToEnum# (n Happy_GHC_Exts.>=# m)) :: Prelude.Bool)
#define EQ(n,m) ((Happy_GHC_Exts.tagToEnum# (n Happy_GHC_Exts.==# m)) :: Prelude.Bool)
#else
#define LT(n,m) (n Happy_GHC_Exts.<# m)
#define GTE(n,m) (n Happy_GHC_Exts.>=# m)
#define EQ(n,m) (n Happy_GHC_Exts.==# m)
#endif



















data Happy_IntList = HappyCons Happy_GHC_Exts.Int# Happy_IntList








































infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is ERROR_TOK, it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept 0# tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
        (happyTcHack j (happyTcHack st)) (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action



happyDoAction i tk st
        = {- nothing -}
          case action of
                0#           -> {- nothing -}
                                     happyFail (happyExpListPerState ((Happy_GHC_Exts.I# (st)) :: Prelude.Int)) i tk st
                -1#          -> {- nothing -}
                                     happyAccept i tk st
                n | LT(n,(0# :: Happy_GHC_Exts.Int#)) -> {- nothing -}
                                                   (happyReduceArr Happy_Data_Array.! rule) i tk st
                                                   where rule = (Happy_GHC_Exts.I# ((Happy_GHC_Exts.negateInt# ((n Happy_GHC_Exts.+# (1# :: Happy_GHC_Exts.Int#))))))
                n                 -> {- nothing -}
                                     happyShift new_state i tk st
                                     where new_state = (n Happy_GHC_Exts.-# (1# :: Happy_GHC_Exts.Int#))
   where off    = happyAdjustOffset (indexShortOffAddr happyActOffsets st)
         off_i  = (off Happy_GHC_Exts.+# i)
         check  = if GTE(off_i,(0# :: Happy_GHC_Exts.Int#))
                  then EQ(indexShortOffAddr happyCheck off_i, i)
                  else Prelude.False
         action
          | check     = indexShortOffAddr happyTable off_i
          | Prelude.otherwise = indexShortOffAddr happyDefActions st




indexShortOffAddr (HappyA# arr) off =
        Happy_GHC_Exts.narrow16Int# i
  where
        i = Happy_GHC_Exts.word2Int# (Happy_GHC_Exts.or# (Happy_GHC_Exts.uncheckedShiftL# high 8#) low)
        high = Happy_GHC_Exts.int2Word# (Happy_GHC_Exts.ord# (Happy_GHC_Exts.indexCharOffAddr# arr (off' Happy_GHC_Exts.+# 1#)))
        low  = Happy_GHC_Exts.int2Word# (Happy_GHC_Exts.ord# (Happy_GHC_Exts.indexCharOffAddr# arr off'))
        off' = off Happy_GHC_Exts.*# 2#




{-# INLINE happyLt #-}
happyLt x y = LT(x,y)


readArrayBit arr bit =
    Bits.testBit (Happy_GHC_Exts.I# (indexShortOffAddr arr ((unbox_int bit) `Happy_GHC_Exts.iShiftRA#` 4#))) (bit `Prelude.mod` 16)
  where unbox_int (Happy_GHC_Exts.I# x) = x






data HappyAddr = HappyA# Happy_GHC_Exts.Addr#


-----------------------------------------------------------------------------
-- HappyState data type (not arrays)













-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state 0# tk st sts stk@(x `HappyStk` _) =
     let i = (case Happy_GHC_Exts.unsafeCoerce# x of { (Happy_GHC_Exts.I# (i)) -> i }) in
--     trace "shifting the error token" $
     happyDoAction i tk new_state (HappyCons (st) (sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state (HappyCons (st) (sts)) ((happyInTok (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_0 nt fn j tk st@((action)) sts stk
     = happyGoto nt j tk st (HappyCons (st) (sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@((HappyCons (st@(action)) (_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (happyGoto nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_2 nt fn j tk _ (HappyCons (_) (sts@((HappyCons (st@(action)) (_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (happyGoto nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_3 nt fn j tk _ (HappyCons (_) ((HappyCons (_) (sts@((HappyCons (st@(action)) (_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (happyGoto nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k Happy_GHC_Exts.-# (1# :: Happy_GHC_Exts.Int#)) sts of
         sts1@((HappyCons (st1@(action)) (_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (happyGoto nt j tk st1 sts1 r)

happyMonadReduce k nt fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k (HappyCons (st) (sts)) of
        sts1@((HappyCons (st1@(action)) (_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> happyGoto nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k (HappyCons (st) (sts)) of
        sts1@((HappyCons (st1@(action)) (_))) ->
         let drop_stk = happyDropStk k stk

             off = happyAdjustOffset (indexShortOffAddr happyGotoOffsets st1)
             off_i = (off Happy_GHC_Exts.+# nt)
             new_state = indexShortOffAddr happyTable off_i




          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop 0# l = l
happyDrop n (HappyCons (_) (t)) = happyDrop (n Happy_GHC_Exts.-# (1# :: Happy_GHC_Exts.Int#)) t

happyDropStk 0# l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n Happy_GHC_Exts.-# (1#::Happy_GHC_Exts.Int#)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction


happyGoto nt j tk st = 
   {- nothing -}
   happyDoAction j tk new_state
   where off = happyAdjustOffset (indexShortOffAddr happyGotoOffsets st)
         off_i = (off Happy_GHC_Exts.+# nt)
         new_state = indexShortOffAddr happyTable off_i




-----------------------------------------------------------------------------
-- Error recovery (ERROR_TOK is the error token)

-- parse error if we are in recovery and we fail again
happyFail explist 0# tk old_st _ stk@(x `HappyStk` _) =
     let i = (case Happy_GHC_Exts.unsafeCoerce# x of { (Happy_GHC_Exts.I# (i)) -> i }) in
--      trace "failing" $ 
        happyError_ explist i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  ERROR_TOK tk old_st CONS(HAPPYSTATE(action),sts) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        DO_ACTION(action,ERROR_TOK,tk,sts,(saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail explist i tk (action) sts stk =
--      trace "entering error recovery" $
        happyDoAction 0# tk action sts ((Happy_GHC_Exts.unsafeCoerce# (Happy_GHC_Exts.I# (i))) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = Prelude.error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions


happyTcHack :: Happy_GHC_Exts.Int# -> a -> a
happyTcHack x y = y
{-# INLINE happyTcHack #-}


-----------------------------------------------------------------------------
-- Seq-ing.  If the --strict flag is given, then Happy emits 
--      happySeq = happyDoSeq
-- otherwise it emits
--      happySeq = happyDontSeq

happyDoSeq, happyDontSeq :: a -> b -> b
happyDoSeq   a b = a `Prelude.seq` b
happyDontSeq a b = b

-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.


{-# NOINLINE happyDoAction #-}
{-# NOINLINE happyTable #-}
{-# NOINLINE happyCheck #-}
{-# NOINLINE happyActOffsets #-}
{-# NOINLINE happyGotoOffsets #-}
{-# NOINLINE happyDefActions #-}

{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.
