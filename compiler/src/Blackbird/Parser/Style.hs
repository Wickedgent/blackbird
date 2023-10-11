--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett and Dan Doel 2013
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable
--
-- This module provides the style information for tokenizing of
-- various portions of the language.
--------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
module Blackbird.Parser.Style
  ( termIdent
  , typeIdent
  , kindIdent
  , personIdent
  , termIdentifier
  , typeIdentifier
  , kindIdentifier
  , personIdentifier
  , op
  , operator
  , termCon
  , typeCon
  ) where

import Control.Applicative
import Control.Lens hiding (op)
import Data.HashSet as HashSet
import Data.Text (Text)
import Blackbird.Parser.Keywords
import Text.Parser.Char
import Text.Parser.Token (TokenParsing, IdentifierStyle(..), ident, reserve, styleName, styleReserved)
import Text.Parser.Token.Highlight
import Text.Parser.Token.Style

variable :: TokenParsing m => IdentifierStyle m
variable = IdentifierStyle
        { _styleName = "variable"
        , _styleStart = lower
        , _styleLetter = alphaNum <|> oneOf "_'"
        , _styleReserved = HashSet.empty
        , _styleHighlight = Identifier
        , _styleReservedHighlight = ReservedIdentifier
        }

personIdent :: TokenParsing m => IdentifierStyle m
personIdent = IdentifierStyle
        { _styleName = "participant"
        , _styleStart = char '@'
        , _styleLetter = alphaNum <|> char '.'
        , _styleReserved = HashSet.empty
        , _styleHighlight = Identifier
        , _styleReservedHighlight = ReservedIdentifier
        }

baseIdent, termIdent, typeIdent, kindIdent :: TokenParsing m => IdentifierStyle m

-- | The base identifier language for variables.
--
-- TODO: make keywords more specific to each level
baseIdent = haskellIdents & styleReserved .~ keywords

-- | The identifier style for term variables.
termIdent = baseIdent & styleName .~ "term variable"

-- | The identifier style for type variables.
typeIdent = variable & styleName .~ "type variable"

-- | The identifier style for kind variables.
kindIdent = baseIdent & styleName .~ "kind variable"

-- | Parse a term identifier.
termIdentifier :: (Monad m, TokenParsing m) => m Text
termIdentifier = ident termIdent

-- | Parse a type identifier
typeIdentifier :: (Monad m, TokenParsing m) => m Text
typeIdentifier = ident typeIdent

-- | Parse a kind identifier
kindIdentifier :: (Monad m, TokenParsing m) => m Text
kindIdentifier = ident kindIdent

-- | Parse a person identifier
personIdentifier :: (Monad m, TokenParsing m) => m Text
personIdentifier = ident personIdent

-- | The identifier style for operators.
--
-- TODO: make this more specific to each level?
op :: TokenParsing m => IdentifierStyle m
op = haskellOps

-- | Parse an operator.
operator :: (Monad m, TokenParsing m) => m Text
operator = ident op <|> ("and" <$ reserve termIdent "and") <|> ("or" <$ reserve termIdent "or")

constructor :: TokenParsing m => IdentifierStyle m
constructor = IdentifierStyle
        { _styleName = "constructor"
        , _styleStart = upper
        , _styleLetter = alphaNum <|> oneOf "_'"
        , _styleReserved = HashSet.empty
        , _styleHighlight = Constructor
        , _styleReservedHighlight = ReservedConstructor
        }

-- | Specifies the data constructor identifier style
termCon :: TokenParsing m => IdentifierStyle m
termCon = constructor & styleName .~ "term constructor"

-- | Specifies the type constructor identifier style
typeCon :: TokenParsing m => IdentifierStyle m
typeCon = constructor & styleName .~ "type constructor"
