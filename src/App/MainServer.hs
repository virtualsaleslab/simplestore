{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module App.MainServer where

import           App.AdminServer
import           App.AuthServer
import           App.ProjectServer
import           App.TenantServer
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
