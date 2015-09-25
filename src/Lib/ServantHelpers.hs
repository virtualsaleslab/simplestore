module Lib.ServantHelpers(Server,Proxy(..),err400, err404,liftIO,maybeErr) where

import Control.Monad.IO.Class     (MonadIO, liftIO)
import Control.Monad.Trans.Except
import Servant(ServantErr,Proxy(..))
import Servant.Server


maybeErr ::  (MonadIO m) => a -> IO (Maybe b) -> ExceptT a m b
maybeErr err x = do
    m <- liftIO x
    case m of
      Nothing -> throwE err
      Just v -> return v
