{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module App.TenantServer(TenantAPI,tenantServer) where

import           Lib.DB.Tenant
import           Lib.ServantHelpers
import           Models
import           Servant.API

type TenantAPI  =  "tenants" :> (
                   Get '[JSON] Tenants
              :<|> Capture "tId" TenantId :> Get '[JSON] Tenant
              :<|> ReqBody '[JSON] Tenant :> Post '[JSON] Tenant
              :<|> Capture "tId" TenantId :> Delete '[JSON] TenantId)

tenantServer :: Server TenantAPI
tenantServer = liftIO getTenants
          :<|> liftIOMaybeToExceptT err404 . findTenant
          :<|> liftIOMaybeToExceptT err400 . insertTenant
          :<|> liftIO . deleteTenant
