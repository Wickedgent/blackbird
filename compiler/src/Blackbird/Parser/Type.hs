{-# LANGUAGE TupleSections #-}
{-# LANGUAGE LambdaCase #-}
--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett and Dan Doel 2012
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable
--
-- This module provides the parser for types
--------------------------------------------------------------------
module Blackbird.Parser.Type
  ( Ann
  , Typ
  , typ
  , typ0
  , annotation
  , typVarBinding
  , typVarBindings
  , someTypVarBindings
  , quantifier
  , quantBindings
  ) where

import Bound
import Bound.Var
import Control.Applicative
import Control.Lens (folded, filtered, to, (^..))
import Data.Text (Text)
import Data.Traversable (for)
import Data.Void
import Blackbird.Builtin.Type
import Blackbird.Parser.Kind
import Blackbird.Parser.Style
import Blackbird.Parser.Trifecta (braces, parens)
import Blackbird.Syntax
import Blackbird.Syntax.Hint (Hint)
import Blackbird.Syntax.Kind as Kind hiding (Var, constraint)
import qualified Blackbird.Syntax.Type as S
import Blackbird.Syntax.Type hiding (Typ)
import Text.Parser.Combinators
import Text.Parser.Token (TokenParsing, colon, comma, commaSep, dot, ident, reserve, symbol)

type Ann = Annot Void Text
type Typ = S.Typ (Maybe Text) (Var Text Text)

banana :: (Monad m, TokenParsing m) => m a -> m a
banana p = reserve op "(|" *> p <* reserve op "|)"

typic :: (Monad m, TokenParsing m) => m Typ
typic
   = Var . B <$> typeIdentifier
 <|> Var . F <$> ident typeCon

-- | Parse an atomic type
typ0 :: (Monad m, TokenParsing m) => m Typ
typ0 = typic
   <|> banana ( Var . B <$ reserve op ".." <*> typeIdentifier
            <|> concreteRho <$> commaSep (ident typeCon)
              )
   <|> parens ( arrow <$ reserve op "->"
            <|> tuple . (+1) . length <$> some comma
            <|> tup' <$> commaSep anyTyp
              )

typ1 :: (Monad m, TokenParsing m) => m Typ
typ1 = apps <$> typ0 <*> many typ0

-- TODO: typ2 shunting yard
typ2 :: (Monad m, TokenParsing m) => m Typ
typ2 = chainr1 typ1 ((~~>) <$ symbol "->")

-- | Parses an optionally annotated type variable.
--
--   typVarBinding ::= ( ident : kind )
--                   | ident
typVarBinding :: (Monad m, TokenParsing m) => m ([Text], Kind (Maybe Text))
typVarBinding = flip (,) unk <$> simpleTypVarBinding
            <|> parens ((,) <$> some typeIdentifier <* colon <*> (fmap Just <$> kind))
 where
 unk :: Kind (Maybe Text)
 unk = pure Nothing

simpleTypVarBinding :: (Monad m, TokenParsing m) => m [Text]
simpleTypVarBinding = some typeIdentifier

-- | Parses a series of type var bindings, processing the result to a more
-- usable format.
--
--   typVarBindings ::= empty | someTypVarBindings
typVarBindings :: (Monad m, TokenParsing m) => m [(Var Text a, Kind (Maybe Text))]
typVarBindings = concatMap (\(vs, k) -> flip (,) k . B <$> vs) <$> many typVarBinding

-- | Parses a series of type var bindings, processing the result to a more
-- usable format.
--
--   someTypVarBindings ::= typVarBinding typVarBindings
someTypVarBindings :: (Monad m, TokenParsing m) => m [(Var Text a, Kind (Maybe Text))]
someTypVarBindings = concatMap (\(vs, k) -> flip (,) k . B <$> vs) <$> some typVarBinding

-- | Parses the bound variables for a quantifier.
--
--   quantBindings ::= {kindVars}
--                   | someTypVarBindings
--                   | {kindVars} typVarBindings
quantBindings :: (Monad m, TokenParsing m) => m ([Text], [(Var Text a, Kind (Maybe Text))])
quantBindings = optional (braces $ some typeIdentifier) >>= \mks -> case mks of
  Just ks -> (,) ks <$> typVarBindings
  Nothing -> (,) [] <$> someTypVarBindings

simpleQuantBindings :: (Monad m, TokenParsing m) => m ([Text], [Text])
simpleQuantBindings = optional (braces $ some kindIdentifier) >>= \mks -> case mks of
  Just ks -> (,) ks <$> many typeIdentifier
  Nothing -> (,) [] <$> some typeIdentifier

-- | Parses a quantifier.
--
--   quantifier ::= Q quantBindings .
quantifier :: (Monad m, TokenParsing m)
           => String -> m ([Text], [(Var Text a, Kind (Maybe Text))])
quantifier q = symbol q *> quantBindings <* dot

-- | Parser for a context that expects 0 or more constraints, together
--
--   constraints ::= constraints1
--                 | empty
--   constraints1 ::= constraint , constraints1
--                  | constraint
constraints :: (Monad m, TokenParsing m) => m Typ
constraints = allConstraints <$> commaSep constraint

-- | Parser for a context that expects a single constraint.
--   constraint ::= exists <vs>. constraint
--                | ( constraints )
--                | ident
constraint :: (Monad m, TokenParsing m) => m Typ
constraint =
      buildE <$ symbol "exists" <*> quantBindings <* dot <*> constraint
  <|> parens constraints
  <|> apps lame <$ symbol "Lame" <*> many typ0
  <|> apps fromInteg <$ symbol "FromInteger" <*> many typ0
  -- Single constraints
  <|> typic
 where buildE (kvs, tvks) =
         exists id (unvar Just Just) (Just <$> kvs) tvks

typ3 :: (Monad m, TokenParsing m) => m Typ
typ3 = forAll id (unvar Just Just) [] [] <$> try (constraint <* reserve op "=>") <*> typ4
    <|> typ2

typ4 :: (Monad m, TokenParsing m) => m Typ
typ4 =  build <$ symbol "forall" <*> quantBindings <* dot <*> typ4
    <|> typ3
 where
 build (kvs, tvks) = forAll id (unvar Just Just) (Just <$> kvs) tvks (And [])

-- | Parse a 'Type'.
typ :: (Monad m, TokenParsing m) => m Typ
typ = typ4

-- anyTyp = exists | typ
anyTyp :: (Monad m, TokenParsing m) => m Typ
anyTyp = typ

annotation :: (MonadFail m, TokenParsing m) => m Ann
annotation = do
  xs <- build <$> optional (symbol "some" *> simpleQuantBindings <* dot) <*> typ
  for xs $ unvar (\x -> fail $ "bound variable in annotation: " ++ show x) pure
 where
   build mkvs t = annot Just (unvar Just Just) ks vs (quant vs t)
     where (ks, vs) = maybe ([],[]) (fmap $ fmap B) mkvs
   quant ss t = forAll id (unvar Just Just) [] ts (And []) t
     where
     ts :: [(Var Text Text, Kind Hint)]
     ts = t^..folded.filtered (`notElem` ss).to (, pure Nothing)
