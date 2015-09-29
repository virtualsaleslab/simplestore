{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module App.MainServer where

import           App.AdminServer
import           App.ProjectServer
import           App.TenantServer
import           App.AuthServer
import           Lib.ServantHelpers
import           Servant.API

type MainAPI =  TenantAPI
           :<|> ProjectAPI
           :<|> AdminAPI
           :<|> AuthAPI

mainAPI :: Proxy MainAPI
mainAPI = Proxy

mainServer :: Server MainAPI
mainServer =    tenantServer
           :<|> projectServer
           :<|> adminServer
           :<|> authServer
