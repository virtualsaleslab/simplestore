module ServantHelpers(Server,Proxy(..),err400, err404,liftIO,liftIOMaybeToEither) where

import Control.Monad.IO.Class     (MonadIO, liftIO)
import Control.Monad.Trans.Either (EitherT, left, right)
import Servant(ServantErr,Proxy(..))
import Servant.Server


liftIOMaybeToEither ::  (MonadIO m) => a -> IO (Maybe b) -> EitherT a m b
liftIOMaybeToEither err x = do
    m <- liftIO x
    case m of
      Nothing -> left err
      Just x -> right x
