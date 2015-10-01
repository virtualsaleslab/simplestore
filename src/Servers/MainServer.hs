{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module Servers.MainServer where

import           Servers.AdminServer
import           Servers.AuthServer
import           Servers.ProjectServer
import           Servers.TenantServer
import           Lib.ServantHelpers
import           Servant.API

type MainAPI =  AdminAPI
           :<|> AuthAPI
           :<|> ProjectAPI
           :<|> TenantAPI


mainAPI :: Proxy MainAPI
mainAPI = Proxy

mainServer :: Server MainAPI
mainServer =    adminServer
           :<|> authServer
           :<|> projectServer
           :<|> tenantServer
