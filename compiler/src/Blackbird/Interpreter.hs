{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett and Dan Doel 2014
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable
--
--------------------------------------------------------------------

module Blackbird.Interpreter
  ( Address
  , peek
  , Closure(..)
  , closureCode
  , closureEnv
  , papArity
  , allocPrimOp
  , allocGlobal
  , Env(..)
  , Frame(..)
  , MachineState(..)
  , trace
  , stackB
  , stackU
  , stackN
  , sp
  , fp
  , eval
  , defaultMachineState
  , primOpNZ
  , primOpN
  , primOpNN
  , primOpUN
  , primOpNU
  , primOpNNN
  , primOpUNN
  , primOpUUU
  ) where

import Control.Applicative hiding (empty)
import Control.Monad.Primitive
import Control.Monad.State
import Control.Lens hiding (au)
import Data.Default
import Data.HashMap.Strict (HashMap)
import qualified Data.Foldable as F
import Data.Maybe
import qualified Data.Map as Map
import Data.Monoid hiding (Any)
import Data.Primitive.MutVar
import Data.Vector (Vector)
import qualified Data.Vector as B
import qualified Data.Vector.Generic as G
import qualified Data.Vector.Generic.Mutable as GM
import qualified Data.Vector.Mutable as BM
import qualified Data.Vector.Primitive as P
import qualified Data.Vector.Primitive.Mutable as PM
import Data.Word
import Blackbird.Core.Compiler (SortRef, compileBinding)
import Blackbird.Syntax.Convention (Convention)
import Blackbird.Syntax.Core (Core)
import Blackbird.Syntax.G
import Blackbird.Syntax.Id
import Blackbird.Syntax.Sort
import Prelude hiding (log)
import Unsafe.Coerce

newtype Address m = Address (MutVar (PrimState m) (Closure m))
  deriving Eq

data Env m = Env
  { _envB :: Vector (Address m)
  , _envU :: P.Vector Word64
  , _envN :: Vector Native
  }

instance Default (Env m) where
  def = Env mempty mempty mempty

data Closure m
  = Closure
    { _closureCode :: !LambdaForm
    , _closureEnv  :: !(Env m)
    }
  | PartialApplication
    { _closureCode :: !LambdaForm
    , _closureEnv  :: !(Env m)
    , _papArity    :: !(Sorted Int) -- remaining args
    }
  | BlackHole
  | PrimClosure (MachineState m -> m (MachineState m))

data Frame m
  = Branch !Continuation !(Env m)
  | Update !(Address m)

data MachineState m = MachineState
  { _sp      :: !(Sorted Int)
  , _fp      :: !(Sorted Int)
  , _stackF  :: [(Sorted Int, Frame m)]
  , _genv    :: HashMap Id (Address m)
  , _trace   :: String -> m ()
  , _stackB  :: BM.MVector (PrimState m) (Address m)
  , _stackU  :: PM.MVector (PrimState m) Word64
  , _stackN  :: BM.MVector (PrimState m) Native
  }

makeClassy ''Env
makeLenses ''MachineState
makeLenses ''Closure

log :: MachineState m -> String -> m ()
log = view trace

note :: Show a => MachineState m -> String -> a -> m ()
note ms n a = log ms (n ++ ": " ++ show a)

{-
watch :: (Monad m, Show a) => MachineState m -> String -> m a -> m a
watch ms n m = do
  a <- m
  note ms n a
  return a
-}

nargs :: MachineState m -> Sorted Int
nargs ms = ms^.fp -ms^.sp

sentinel :: a
sentinel = error "PANIC: access past end of stack"

allocPrimOp :: PrimMonad m => (MachineState m -> m (MachineState m)) -> m (Address m)
allocPrimOp f = Address <$> newMutVar (PrimClosure f)

allocGlobal :: (Eq c, PrimMonad m) => (c -> SortRef) -> Core Convention c -> m (Address m)
allocGlobal cxt core = case compileBinding cxt core of
  PreClosure rs co
    | F.all G.null rs -> Address <$> newMutVar (Closure co def)
    | otherwise -> error "PANIC: allocating global with captures"

defaultMachineState :: PrimMonad m => Int -> HashMap Id (Address m) -> m (MachineState m)
defaultMachineState stackSize ge
    = MachineState (pure stackSize) (pure stackSize) [] ge (const $ return ())
  <$> GM.replicate stackSize sentinel
  <*> GM.replicate stackSize 0
  <*> GM.replicate stackSize sentinel

poke :: PrimMonad m => Address m -> Closure m -> m ()
poke (Address r) c = writeMutVar r c

peek :: PrimMonad m => Address m -> m (Closure m)
peek (Address r) = readMutVar r

resolveEnv
  :: PrimMonad m
  => Env m -> Sorted (Vector Ref) -> MachineState m -> m (Env m)
resolveEnv le (Sorted bs us ns) ms =
  Env <$> G.mapM (resolveClosure le ms) bs
      <*> (G.convert <$> G.mapM (resolveUnboxed le ms) us)
      <*> G.mapM (resolveNative le ms) ns

resolveClosure :: PrimMonad m => Env m -> MachineState m -> Ref -> m (Address m)
resolveClosure le _ (Local l)  = return $ le^?!envB.ix (fromIntegral l)
resolveClosure _ ms (Stack s)  = GM.read (ms^.stackB) (fromIntegral s + ms^.sp.sort B)
resolveClosure _ ms (Global g) = note ms "resolveClosure(global)" g >> (return $ ms^?!genv.ix g)
resolveClosure _ _  Lit{}      = error "resolveClosure: Lit"
resolveClosure _ _  Native{}   = error "resolveClosure: Native"

resolveUnboxed :: PrimMonad m => Env m -> MachineState m -> Ref -> m Word64
resolveUnboxed le _ (Local l)  = return $ le^?!envU.ix (fromIntegral l)
resolveUnboxed _ ms (Stack s)  = GM.read (ms^.stackU) (fromIntegral s + ms^.sp.sort U)
resolveUnboxed _ _  (Lit l)    = return l
resolveUnboxed _ _  Global{}   = error "resolveUnboxed: Global"
resolveUnboxed _ _  Native{}   = error "resolveUnboxed: Native"

resolveNative :: PrimMonad m => Env m -> MachineState m -> Ref -> m Native
resolveNative _ _ (Native a) = return a
resolveNative le _ (Local l) = return $ le^?!envN.ix (fromIntegral l)
resolveNative _ ms (Stack s) = GM.read (ms^.stackN) (fromIntegral s + ms^.sp.sort N)
resolveNative _ _ Lit{}      = error "resolveNative: Lit"
resolveNative _ _ Global{}   = error "resolveNative: Global"

buildClosure :: PrimMonad m => Env m -> PreClosure -> MachineState m -> m (Closure m)
buildClosure le (PreClosure captures code) ms = Closure code <$> resolveEnv le captures ms

allocClosure
  :: PrimMonad m
  => Env m -> PreClosure -> MachineState m -> m (Address m)
allocClosure le cc ms = Address <$> (buildClosure le cc ms >>= newMutVar)

allocRecursive
  :: PrimMonad m
  => Env m -> Vector PreClosure -> MachineState m -> m (MachineState m)
allocRecursive lo ccs ms = do
  let n = B.length ccs
      (sb, ms') = ms & sp.sort B <-~ n
      stk = ms^.stackB
  ifor_ ccs $ \ i _ -> do
    mv <- newMutVar (error "PANIC: allocRecursive: closure isn't")
    GM.write stk (sb + i) (Address mv)
  ifor_ ccs $ \ i pc -> do
    addr <- GM.read stk (sb + i)
    buildClosure lo pc ms' >>= poke addr
  return ms'

pushArgs
  :: PrimMonad m
  => Env m -> Sorted (Vector Ref) -> MachineState m -> m (MachineState m)
pushArgs le refs@(Sorted bs us ns) ms = do
  note ms "pushArgs" (B.length <$> refs)
  let (Sorted sb su sn, ms') = ms & sp <-~ fmap B.length refs
      stkB = ms^.stackB
      stkU = ms^.stackU
      stkN = ms^.stackN
  ifor_ bs $ \i -> resolveClosure le ms >=> GM.write stkB (sb + i)
  ifor_ us $ \i -> resolveUnboxed le ms >=> GM.write stkU (su + i)
  ifor_ ns $ \i -> resolveNative  le ms >=> GM.write stkN (sn + i)
  return $ ms'

push :: Frame m -> MachineState m -> MachineState m
push fr ms
  | F.or ((>) <$> ms^.sp <*> ms^.fp) = error "push inverts stack and frame pointers"
  | otherwise = ms & fp .~ ms^.sp & stackF %~ ((ms^.fp,fr):)

copyArgs :: (PrimMonad m, GM.MVector v a) => v (PrimState m) a -> Int -> Int -> Int -> m ()
copyArgs stk frm off len = GM.mapM_ evalPrim (GM.slice frm len stk) >> GM.move (GM.slice (frm+off-len) len stk) (GM.slice frm len stk)

pop :: PrimMonad m => MachineState m -> m (Maybe (Frame m, MachineState m))
pop = popWith 0

popWith :: PrimMonad m => Sorted Int -> MachineState m -> m (Maybe (Frame m, MachineState m))
popWith args ms = case ms^.stackF of
  (ofp,fr):fs -> do
    let f = ms^.fp
    ms' <- squash (f - ms^.sp) args ms
    return $ Just (fr,ms' & fp .~ ofp & stackF .~ fs)
  [] -> return Nothing

-- for tail calls or return
--
-- In @squash sz args ms@
--
-- @sz@ is the number of local variables and arguments we just pushed
-- @args@ is the number of those local variables that are arguments we had pushed
-- We then squash the variables so that the local variables that were pushed on the end
-- are pushed at the front of this frame and 'suck the air' out of the frame removing
-- all the others
--
-- @
-- Before (w/ stack growing down to the right)
--
-- fp            sp
-- |             |
-- v             v
-- <-----sz------>
--        <-args->
--
-- After
--
-- fp     sp'
-- |      |
-- v      v
-- <-args->
-- @
squash :: PrimMonad m => Sorted Int -> Sorted Int -> MachineState m -> m (MachineState m)
squash sz@(Sorted zb zu zn)  args@(Sorted ab au an) ms = do
  note ms "squash" (sz, args)
  let Sorted sb su sn = ms^.sp
      stkB = ms^.stackB
      stkU = ms^.stackU
      stkN = ms^.stackN
  copyArgs stkB sb zb ab
  copyArgs stkU su zu au
  copyArgs stkN sn zn an
  when (zb > ab) $ GM.set (GM.slice sb (zb-ab) stkB) sentinel
  when (zn > an) $ GM.set (GM.slice sn (zn-an) stkN) sentinel
  return $ ms & sp +~ sz - args

select :: Continuation -> Tag -> G
select (Continuation bs df) t =
  fromMaybe (error "PANIC: missing default case in branch") $
    snd <$> Map.lookup t bs <|> df

extendPayload :: (PrimMonad m, G.Vector v a) => v a -> G.Mutable v (PrimState m) a -> Int -> Int -> m (v a)
extendPayload d stk stp n = do
  let m = G.length d
  me <- GM.new (m + n)
  G.copy (GM.slice 0 m me) d
  GM.copy (GM.slice m n me) (GM.slice stp n stk)
  G.unsafeFreeze me

pushPayload :: (PrimMonad m, G.Vector v a) => Int -> v a -> G.Mutable v (PrimState m) a -> Int -> m ()
pushPayload f e stk stp = G.copy (GM.slice stp (G.length e - f) stk) (G.drop f e)

pushPayloads :: PrimMonad m => Sorted Int -> Env m -> MachineState m -> m (MachineState m)
pushPayloads (Sorted fb fu fn) (Env db du dn) ms = do
  let Sorted sb su sn = ms^.sp
  pushPayload fb db (ms^.stackB) sb
  pushPayload fu du (ms^.stackU) su
  pushPayload fn dn (ms^.stackN) sn
  return $ ms & sp -~ Sorted (G.length db - fb) (G.length du - fu) (G.length dn - fn)

extendPayloads :: PrimMonad m => Env m -> MachineState m -> m (Env m)
extendPayloads (Env db du dn) ms =
  Env <$> extendPayload db (ms^.stackB) sb arb
      <*> extendPayload du (ms^.stackU) su aru
      <*> extendPayload dn (ms^.stackN) sn arn
  where
    Sorted sb su sn = ms^.sp
    Sorted arb aru arn = nargs ms

payload :: (PrimMonad m, G.Vector v a) => G.Mutable v (PrimState m) a -> Int -> Int -> m (v a)
payload mv s n = do
  me <- GM.new n
  GM.copy me (GM.slice s n mv)
  G.unsafeFreeze me

------------------------------------------------------------------------------
-- * The Spineless Tagless G-Machine
------------------------------------------------------------------------------

eval :: (MonadFail m, PrimMonad m) => G -> Env m -> MachineState m -> m (MachineState m)
eval (App sz f xs) le ms = case f of
  Ref r -> do
    addr <- resolveClosure le ms r
    ms'  <- pushArgs le xs ms
    let lxs = G.length <$> xs
    let lsz :: Sorted Int
        lsz = fromIntegral <$> sz
    ms'' <- squash (lsz + lxs) lxs ms'
    enter addr ms''
  Con t -> pushArgs le xs ms >>= returnCon t (G.length <$> xs)
eval (Let bs e) le ms = do
  let stk = ms^.stackB
      (sb, ms') = ms & sp.sort B <-~ G.length bs
  ifor_ bs $ \i pc -> allocClosure le pc ms >>= GM.write stk (sb + i)
  eval e le ms'
eval (LetRec bs e) le ms   = allocRecursive le bs ms >>= eval e le
eval (Case co k) le ms = do log ms "pushBranch: Case" ; eval co le $ push (Branch k le) ms
eval (CaseLit ref k) le ms = do
  l <- resolveUnboxed le ms ref
  returnLit l $ push (Branch k le) ms
eval Slot le ms = do
  pos <- resolveUnboxed le ms (Stack 0)
  slot <- resolveClosure le ms (Local pos)
  squash (Sorted 0 1 0) 0 ms >>= enter slot

enter :: (MonadFail m, PrimMonad m) => Address m -> MachineState m -> m (MachineState m)
enter addr ms = do
 note ms "enter" args
 peek addr >>= \case
  BlackHole -> fail "blackbird <<loop>> detected"
  w@(PartialApplication co da arity)
    | F.sum args < F.sum arity -> pap co da arity w
    | otherwise -> pushPayloads (fmap fromIntegral (co^.free)) da ms >>= eval (co^.body) da
  w@(Closure co da)
    | co^.update -> do log ms "pushUpdate" ; eval (co^.body) da $ push (Update addr) ms
    | arity <- fmap fromIntegral (co^.bound), argcount < F.sum arity -> pap co da arity w
    | otherwise -> eval (co^.body) da ms
  PrimClosure k -> k ms
 where
  args = nargs ms
  argcount = F.sum args
  pap co da arity w
    | argcount == 0 = go w -- entering a function with 0 args
    | otherwise = do
    e <- extendPayloads da ms
    go $ PartialApplication co e (arity - args)
   where
    go k = pop ms >>= \case
      Just (Update ad, ms') -> do
        poke ad k
        enter ad ms'
      Just (Branch (Continuation m (Just dflt)) le', ms') | Map.null m -> eval dflt le' ms'
      Just _  -> error "bad frame after partial application"
      Nothing -> return ms

returnCon :: (MonadFail m, PrimMonad m) => Tag -> Sorted Int -> MachineState m -> m (MachineState m)
returnCon t args@(Sorted ab au an) ms = popWith args ms >>= \case
  Just (Branch k le, ms') -> log ms "popBranch" >> eval (select k t) le ms'
  Just (Update ad, ms') -> do
    log ms "popUpdate"
    let Sorted sb su sn = ms'^.sp
    e <- Env <$> payload (ms'^.stackB) sb ab <*> payload (ms'^.stackU) su au <*> payload (ms'^.stackN) sn an
    poke ad $ Closure (standardConstructor (fromIntegral <$> args) t) e
    returnCon t args ms'
  Nothing -> return ms

returnLit :: (MonadFail m, PrimMonad m) => Word64 -> MachineState m -> m (MachineState m)
returnLit w ms = pop ms >>= \case
  Just (Branch k le, ms') -> eval (select k w) le ms'
  Just _ -> error "PANIC: literal update frame"
  Nothing -> return ms

------------------------------------------------------------------------------
-- Primops
------------------------------------------------------------------------------

-- TODO maybe actually return something here instead of hard abort
primOpNZ :: PrimMonad m => (a -> m ()) -> MachineState m -> m (MachineState m)
primOpNZ f ms = GM.read nstk np >>= f . unsafeCoerce >> return ms
 where
 np = ms^.sp.sort N
 nstk = ms^.stackN

primOpN :: (MonadFail m, PrimMonad m) => m b -> MachineState m -> m (MachineState m)
primOpN f ms =
  f >>= GM.write nstk np . unsafeCoerce
    >> returnCon 0 (Sorted 0 0 1) ms'
 where
 (np, ms') = ms & sp.sort N <-~ 1
 nstk = ms^.stackN

primOpUN :: (MonadFail m, PrimMonad m) => (Word64 -> m b) -> MachineState m -> m (MachineState m)
primOpUN f ms =
  GM.read ustk up >>= f >>= GM.write nstk np . unsafeCoerce
    >> returnCon 0 (Sorted 0 0 1) ms'
 where
 (Sorted _ up np, ms') = ms & sp <-~ Sorted 0 0 1
 nstk = ms^.stackN
 ustk = ms^.stackU

primOpNU :: (MonadFail m, PrimMonad m) => (a -> m Word64) -> MachineState m -> m (MachineState m)
primOpNU f ms =
  GM.read nstk np >>= f . unsafeCoerce >>= GM.write ustk up
    >> returnCon 0 (Sorted 0 1 0) ms'
 where
 (Sorted _ up np, ms') = ms & sp <-~ Sorted 0 1 0
 nstk = ms^.stackN
 ustk = ms^.stackU

primOpNN :: (MonadFail m, PrimMonad m) => (a -> m b) -> MachineState m -> m (MachineState m)
primOpNN f ms =
  GM.read nstk (np+1) >>= f . unsafeCoerce >>= GM.write nstk np . unsafeCoerce
    >> returnCon 0 (Sorted 0 0 1) ms'
 where
 (np, ms') = ms & sp.sort N <-~ 1
 nstk = ms^.stackN

primOpNNN :: (MonadFail m, PrimMonad m) => (a -> b -> m c) -> MachineState m -> m (MachineState m)
primOpNNN f ms = do
  a <- GM.read nstk (np+1)
  b <- GM.read nstk (np+2)
  GM.write nstk np . unsafeCoerce =<< f (unsafeCoerce a) (unsafeCoerce b)
  returnCon 0 (Sorted 0 0 1) ms'
 where
 (np, ms') = ms & sp.sort N <-~ 1
 nstk = ms^.stackN

primOpUNN :: (MonadFail m, PrimMonad m) => (Word64 -> b -> m c) -> MachineState m -> m (MachineState m)
primOpUNN f ms = do
  w1 <- GM.read ustk up
  a <- GM.read nstk (np+1)
  GM.write nstk np . unsafeCoerce =<< f w1 (unsafeCoerce a)
  returnCon 0 (Sorted 0 0 1) ms'
 where
 (np, ms') = ms & sp.sort N <-~ 1
 up = ms ^. sp.sort U
 nstk = ms^.stackN
 ustk = ms^.stackU

primOpUUU :: (MonadFail m, PrimMonad m)
          => (Word64 -> Word64 -> Word64) -> MachineState m -> m (MachineState m)
primOpUUU f ms = do
  w1 <- GM.read ustk (up+1)
  w2 <- GM.read ustk (up+2)
  GM.write ustk up $ f w1 w2
  returnCon 0 (Sorted 0 1 0) ms'
 where
 (up, ms') = ms & sp.sort U <-~ 1
 ustk = ms^.stackU
