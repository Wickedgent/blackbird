{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE DeriveDataTypeable #-}
module Blackbird.Monitor
  ( withMonitor
  -- * The Monitor
  , Monitor(..)
  , HasMonitor(..)
  -- * Gauges
  , Gauge(..)
  , gauge, gaugeM
  -- * Counters
  , Counter(..)
  , counter, counterM
  -- * Labels
  , Label(..)
  , label, labelM
  -- * Compatibilty with EKG
  , Server
  , withServer
  , forkServer
  -- * Modifiers
  , module Blackbird.Monitor.Combinators
  -- * Options
  , module Blackbird.Monitor.Options
  ) where

import Control.Exception
import Control.Lens hiding (Setting)
import Control.Monad.Trans
import Control.Monad.Reader
import Data.ByteString.Lens
import Data.Foldable as F
import Data.Int
import Data.Text
import Blackbird.Monitor.Combinators
import Blackbird.Monitor.Exception
import Blackbird.Monitor.Options
import System.Process
import System.Remote.Monitoring
import qualified System.Remote.Gauge as G
import qualified System.Remote.Counter as C
import qualified System.Remote.Label as L

-- | Enable/disable EKG

data Monitor = Monitor
  { __monitorOptions :: MonitorOptions
  , _monitorServer   :: Maybe Server
  }

makeClassy ''Monitor

instance HasMonitorOptions Monitor where
  monitorOptions = _monitorOptions

withServer :: HasMonitor t => t -> (Server -> IO ()) -> IO ()
withServer t = F.forM_ $ t^.monitorServer

newtype Gauge = Gauge { runGauge :: Maybe G.Gauge }
newtype Label = Label { runLabel :: Maybe L.Label }
newtype Counter = Counter { runCounter :: Maybe C.Counter }

instance Setting Label Text where
  assign (Label t) a = liftIO $ maybe (return ()) (L.set ?? a) t

instance Updating Label Text where
  update (Label t) f = liftIO $ maybe (return ()) (L.modify f) t

instance Setting Gauge Int64 where
  assign (Gauge t) a = liftIO $ maybe (return ()) (G.set ?? a) t

instance Gauged Gauge Int64 where
  dec (Gauge t)   = liftIO $ maybe (return ()) G.dec t
  sub (Gauge t) i = liftIO $ maybe (return ()) (G.add ?? negate i) t

instance Incremental Gauge where
  inc (Gauge t)   = liftIO $ maybe (return ()) G.inc t
  add (Gauge t) i = liftIO $ maybe (return ()) (G.add ?? i) t

instance Incremental Counter where
  inc (Counter t)   = liftIO $ maybe (return ()) C.inc t
  add (Counter t) i = liftIO $ maybe (return ()) (C.add ?? i) t

gauge :: (MonadIO m, HasMonitor t) => Text -> t -> m Gauge
gauge = runReaderT . gaugeM

counter :: (MonadIO m, HasMonitor t) => Text -> t -> m Counter
counter = runReaderT . counterM

label :: (MonadIO m, HasMonitor t) => Text -> t -> m Label
label = runReaderT . labelM

-- | create a gauge
gaugeM :: (MonadIO m, MonadReader t m, HasMonitor t) => Text -> m Gauge
gaugeM l = view monitorServer >>= maybe (return $ Gauge Nothing) (liftIO . fmap (Gauge . Just) . getGauge l)

-- | create a counter
counterM :: (MonadIO m, MonadReader t m, HasMonitor t) => Text -> m Counter
counterM l = view monitorServer >>= maybe (return $ Counter Nothing) (liftIO . fmap (Counter . Just) . getCounter l)

-- | create a label
labelM :: (MonadIO m, MonadReader t m, HasMonitor t) => Text -> m Label
labelM t = view monitorServer >>= maybe (return $ Label Nothing) (liftIO . fmap (Label . Just) . getLabel t)

withMonitor :: HasMonitorOptions t => t -> (Monitor -> IO a) -> IO a
withMonitor t k
  | t^.monitorEnabled = do
    server <- forkServer (t^.monitorHost.packedChars) (t^.monitorPort)
    let uri = monitorUri t
    putStrLn $ "Monitoring enabled at " ++ uri
    when (t^.monitorOpen) $ do
      _ <- system $ "/usr/bin/open " ++ uri
      return ()
    k (Monitor (t^.monitorOptions) $ Just server) `finally` throwTo (serverThreadId server) ShutdownMonitor
  | otherwise = k $ Monitor (t^.monitorOptions) Nothing
