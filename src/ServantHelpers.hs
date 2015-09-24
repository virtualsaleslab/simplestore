module ServantHelpers(Server,Proxy(..),err400, err404,liftIO,liftIOMaybeToExceptT) where

import Control.Monad.IO.Class     (MonadIO, liftIO)
import Control.Monad.Trans.Except
import Servant(ServantErr,Proxy(..))
import Servant.Server


liftIOMaybeToExceptT ::  (MonadIO m) => a -> IO (Maybe b) -> ExceptT a m b
liftIOMaybeToExceptT err x = do
    m <- liftIO x
    case m of
      Nothing -> throwE err
      Just v -> return v
