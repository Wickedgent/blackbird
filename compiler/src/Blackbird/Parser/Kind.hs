--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett and Dan Doel 2012-2013
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable
--
-- This module provides the parser for kinds.
--------------------------------------------------------------------
module Blackbird.Parser.Kind
  ( kind
  ) where

import Control.Applicative
import Data.Text (Text)
import Blackbird.Parser.Style
import Blackbird.Parser.Trifecta (parens)
import Blackbird.Syntax.Kind
import Text.Parser.Combinators
import Text.Parser.Token (TokenParsing, reserve, symbol)

-- | Parse an atomic kind (everything but arrows)
kind0 :: (Monad m, TokenParsing m) => m (Kind Text)
kind0 = parens kind
    <|> star <$ symbol "*"
    <|> rho <$ reserve kindIdent "rho"
    <|> rho <$ reserve kindIdent "ρ"
    <|> phi <$ reserve kindIdent "phi"
    <|> phi <$ reserve kindIdent "φ"
    <|> unboxed <$ reserve kindIdent "#"
    <|> constraint <$ reserve kindIdent "constraint"
    <|> constraint <$ reserve kindIdent "Γ"
    <|> Var <$> kindIdentifier

-- | Parse a 'Kind'
kind :: (Monad m, TokenParsing m) => m (Kind Text)
kind = chainr1 kind0 ((:->) <$ symbol "->")
