{-# LANGUAGE OverloadedStrings #-}
--------------------------------------------------------------------
-- |
-- Copyright :  (c) Dan Doel 2013
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable
--
-- This module provides a parser for global names.
--
-- Note: most parsing goes through strings, which are later fixed
-- up into global names, but in some cases globals should be parsed
-- directly.
--------------------------------------------------------------------

module Blackbird.Parser.Global
  ( globalIdent
  ) where

import Blackbird.Syntax.Global
import Blackbird.Syntax.ModuleName
import Text.Parser.Token (IdentifierStyle, TokenParsing, ident)

-- | Parse a global identifier with the given style.
--
-- TODO: package/module information
globalIdent :: (Monad m, TokenParsing m) => IdentifierStyle m -> m Global
globalIdent style = glob Idfix (mkModuleName_ "Blackbird") <$> ident style
