module Lib.ServantHelpers(Server,Proxy(..),err400, err401, err404,liftIO,ioMaybeToExceptT,maybeToExceptT) where

import           Control.Monad.IO.Class     (MonadIO, liftIO)
import           Control.Monad.Trans.Except (ExceptT, throwE)
import           Servant                    (Proxy (..), ServantErr)
import           Servant.Server

maybeToExceptT :: MonadIO m => e -> Maybe t -> ExceptT e m t
maybeToExceptT err x =
    case x of
      Just v -> return v
      Nothing -> throwE err


ioMaybeToExceptT :: MonadIO m => e -> IO (Maybe t) -> ExceptT e m t
ioMaybeToExceptT err x = do
    m <- liftIO x
    maybeToExceptT err m
