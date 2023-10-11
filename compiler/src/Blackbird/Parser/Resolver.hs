{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}

--------------------------------------------------------------------
-- |
-- Copyright :  (c) McGraw Hill Financial 2015
-- License   :  BSD2
-- Maintainer:  Qredo LTD <support@qredo.com>
-- Stability :  experimental
-- Portability: non-portable
--
-- This module resolution for globals and imports.
--------------------------------------------------------------------

module Blackbird.Parser.Resolver
  ( resolveImport
  ) where

import Control.Lens
import Data.Hashable (Hashable)
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as HM
import Data.HashSet (HashSet)
import qualified Data.HashSet as HS
import Data.Maybe (fromJust)
import Data.Text (Text, pack, unpack)
import Data.Traversable (forM)
import Blackbird.Syntax.Global (Global, Fixity(..), glob, global)
import Blackbird.Syntax.Module hiding (explicit, fixityDecl, moduleHead)
import Blackbird.Syntax.ModuleName
import Blackbird.Syntax.Name

-- | Completely resolve an Import.
resolveImport :: forall m. MonadFail m =>
  Import Text -> -- The import to be resolved.
  Module      -> -- The module the import references.
  m ImportResolution
resolveImport imp md = do
  let termNms  = moduleTermNames md
      typeNms  = moduleTypeNames md
      resolver :: Explicit Text -> m (Explicit Global)
      resolver = resolveGlobal termNms typeNms
  i    <- (importScope'.importScopeExplicits.traverse) resolver imp
  let mapResolver :: HashMap Text Global -> m (HashMap Text (HashSet Global))
      mapResolver = resolveImportMap i
  trms <- mapResolver termNms
  typs <- mapResolver typeNms
  return $ ImportResolution [i] (ResolvedTerms trms) (ResolvedTypes typs)

-- | Resolve the explicit imports/hidings in an 'Import', in
-- accordance with the associated 'Module'.  Replace all 'Text' with
-- 'Global', or fail if a name isn't found in the 'Module'.
resolveGlobal :: MonadFail m => 
  HashMap Text Global -> HashMap Text Global -> Explicit Text -> m (Explicit Global)
resolveGlobal termNms typeNms expl = expl `forM` \txt ->
    HM.lookup txt (if (expl^.explicitIsType) then typeNms else termNms)
    -- TODO better error message
    & maybe (fail $ "Missing name " <> unpack txt) return

-- | Resolve (determine) all the terms or types imported by the given Import
-- The results values are Sets, because of the following corner case:
-- import X using (x as y), where X already exports y.
-- The result is appropriately filtered based on the Imports using/hiding clause.
resolveImportMap :: forall m. MonadFail m => 
  Import Global       ->  -- the import, obvs
  HashMap Text Global ->  -- map of all the term or type globals in the module
  m (HashMap Text (HashSet Global))
resolveImportMap imp modTerms = r (imp^.importScope) where
  -- create a Map of Globals from some Explicits
  impGlobMap :: [Explicit Global] -> HashMap Text Global
  impGlobMap exps  = HM.fromList $ fmap p exps where
    p (Explicit g _ _) = (g^.name, g)
  {-
    With a using clause, each key in impGlobMap must be in modTerms, 
    or the module doesn't export it, so error.
    Assuming all the keys are present, we have all the imports,
    and must simply prep the result (see applyRenamings for details).
  -}
  r (Using  exps)  = if   HM.null unfoundTerms 
                     then return $ applyRenamings imp importMap exps
                     else mkErrorMessage where
    importMap      = impGlobMap exps
    unfoundTerms   = HM.difference importMap modTerms
    mkErrorMessage :: m a
    mkErrorMessage = fail "todo"
  {-
    Simply remove all members of impGlobMap from modTerms.
    If we try to hide something that isn't exported, we do not complain.
    (this decision was made via conversation with dolio and edwardk).
  -}
  r (Hiding exps) = return $
    applyRenamings imp (HM.difference modTerms $ impGlobMap exps) exps

-- | Apply renamings from any 'as' clauses, 
-- both at the module level and bindings in using clauses.
applyRenamings ::
  Import Global       ->
  HashMap Text Global -> 
  [Explicit Global]   -> 
  HashMap Text (HashSet Global)
applyRenamings imp gs exps = renameImportAsClause (renameExplicitAsClauses gs exps) (imp^.importAs)

-- | Some Explicits might have an 'as' clause: import X using (x as y).
-- For each of those that are renamed, we must change their entry in the map.
-- This causes us to have to have a Set, because X might already export y.
renameExplicitAsClauses :: 
  HashMap Text Global -> -- The set of imports to be renamed 
  [Explicit Global]   -> -- The list of explicits that might contain renamings
  HashMap Text (HashSet Global)
renameExplicitAsClauses gs exps = foldl f (HM.map HS.singleton gs) exps where
  f m (Explicit _ _ Nothing) = m
  f m (Explicit g _ (Just newName)) = 
    HM.delete (g^.name) $ HM.adjust h (pack newName) m where
      h :: (HashSet Global -> HashSet Global)
      h = HS.union $ fromJust $ HM.lookup (g^.name) m

-- | And Import might have an 'as' clause: import A as B.
-- In this case, each of the keys must be renamed to key_A. 
-- (Note: This is a different convention than Haskell's A.key)
renameImportAsClause :: HashMap Text a -> Maybe String -> HashMap Text a
renameImportAsClause m = maybe m (flip (mapKeys.appendAs) m) where
  appendAs as k = pack $ unpack k ++ "_" ++ as

-- | Specialization of the usual 'mapKeys' that optimizes the "same
-- key" case by requiring the key type doesn't change.
mapKeys :: Hashable k => (k -> k) -> HashMap k a -> HashMap k a
mapKeys f m = HM.foldrWithKey g m m where
  g k v m' = let k' = f k in if k == k' then m' else HM.delete k $ HM.insert k' v m'

-- The following few functions extracted to the top level because
-- maybe they should live in Ermine.Syntax.Module.

-- | To get Globals for for all Terms in a Module:
--  * Create Globals from moduleFixities (with given fixity, just for terms)
--  * Create Globals from moduleBindings (with Idfix)
--  * Union those two maps (biased on first map)
moduleTermNames :: Module -> HashMap Text Global
moduleTermNames md =  fixityTermGlobals md `HM.union` bindingGlobals md

-- | To get Globals for all Types in a Module:
--  * Create  Globals from moduleFixities (with given fixity, types for types)
--  * Extract Globals from moduleData.
--  * Union those two maps (biased on first map)
moduleTypeNames :: Module -> HashMap Text Global
moduleTypeNames md = fixityTypeGlobals md `HM.union` dataTypeGlobals md

fixityTermGlobals :: Module -> HashMap Text Global
fixityTermGlobals = fixityGlobals TermLevel

fixityTypeGlobals :: Module -> HashMap Text Global
fixityTypeGlobals = fixityGlobals TypeLevel

fixityGlobals :: FixityDeclLevel -> Module -> HashMap Text Global
fixityGlobals level md = HM.fromList globs where
  globs :: [(Text, Global)]
  globs = fmap fixityDeclGlobals $ filter levelFilter (md^.moduleFixities) >>= fixityDeclFixities
  levelFilter :: FixityDecl -> Bool
  levelFilter fd = level == (fd^.fixityDeclType)
  fixityDeclFixities :: FixityDecl -> [(Text, Fixity)]
  fixityDeclFixities fd = fmap (\t -> (t, fd^.fixityDeclFixity)) (fd^.fixityDeclNames)
  fixityDeclGlobals :: (Text, Fixity) -> (Text, Global)
  fixityDeclGlobals (t, f) = (t, glob f (md^.moduleName) t)

bindingGlobals :: Module -> HashMap Text Global
bindingGlobals md = HM.fromList $ fmap f (md^.moduleBindings) where
  f (_, t, _) = (t, glob Idfix (md^.moduleName) t)

dataTypeGlobals :: Module -> HashMap Text Global
dataTypeGlobals md = HM.fromList $ fmap (f.snd) (md^.moduleData) where
  f dt = (dt^.name, dt^.global)

