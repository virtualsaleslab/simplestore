module Lib.ServantHelpers(Server,Proxy(..),err400, err401, err403, err404,liftIO,ioMaybeToEitherT,maybeToEitherT,left) where

import           Control.Monad.IO.Class     (MonadIO, liftIO)
import           Control.Monad.Trans.Either (EitherT, left)
import           Servant                    (Proxy (..), ServantErr)
import           Servant.Server

maybeToEitherT :: MonadIO m => e -> Maybe t -> EitherT e m t
maybeToEitherT err x =
    case x of
      Just v -> return v
      Nothing -> left err


ioMaybeToEitherT :: MonadIO m => e -> IO (Maybe t) -> EitherT e m t
ioMaybeToEitherT err x = do
    m <- liftIO x
    maybeToEitherT err m
