{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module App.MainServer where

import           Lib.ServantHelpers
import           Servant.API
import           App.AdminServer
import           App.ProjectServer
import           App.TenantServer



type MainAPI =  TenantAPI
           :<|> ProjectAPI
           :<|> AdminAPI

mainAPI :: Proxy MainAPI
mainAPI = Proxy

mainServer :: Server MainAPI
mainServer = tenantServer
           :<|> projectServer
           :<|> adminServer
