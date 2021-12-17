{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE MonoLocalBinds #-}

module Cardano.Node.Protocol.Types
  ( Protocol(..)
  , SomeConsensusProtocol(..)
  , protocolName
  ) where

import           Prelude (String)
import           Cardano.Prelude

import           Control.Monad.Fail (fail)
import           Data.Aeson
import           NoThunks.Class (NoThunks)

import qualified Cardano.Api.Protocol.Types as Cardano

import           Cardano.Node.Orphans ()
import           Cardano.Node.Queries (HasKESInfo, HasKESMetricsData)
import           Cardano.Node.TraceConstraints (TraceConstraints)


data Protocol = ByronProtocol
              | ShelleyProtocol
              | CardanoProtocol
  deriving (Eq, Show, Generic)

deriving instance NFData Protocol
deriving instance NoThunks Protocol

instance FromJSON Protocol where
  parseJSON =
    withText "Protocol" $ \str -> case str of

      -- The new names
      "Byron" -> pure ByronProtocol
      "Shelley" -> pure ShelleyProtocol
      "Cardano" -> pure CardanoProtocol

      -- The old names
      "RealPBFT" -> pure ByronProtocol
      "TPraos" -> pure ShelleyProtocol

      _ -> fail $ "Parsing of Protocol failed. "
                <> show str <> " is not a valid protocol"

data SomeConsensusProtocol where

     SomeConsensusProtocol :: forall blk. ( Cardano.Protocol IO blk
                                          , HasKESMetricsData blk
                                          , HasKESInfo blk
                                          , TraceConstraints blk
                                          )
                           => Cardano.BlockType blk
                           -> Cardano.ProtocolInfoArgs IO blk
                           -> SomeConsensusProtocol

-- | A human readable name for the protocol
--
protocolName :: Protocol -> String
protocolName ByronProtocol   = "Byron"
protocolName ShelleyProtocol = "Shelley"
protocolName CardanoProtocol = "Byron; Shelley"
