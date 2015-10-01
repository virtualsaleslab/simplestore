{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module Servers.TenantServer(TenantAPI,tenantServer) where

import           DB.Tenant
import           Lib.ServantHelpers
import           Domain.Models
import           Servant.API
import           Data.Aeson   (FromJSON, ToJSON)

instance ToJSON Tenant
instance FromJSON Tenant

type TenantAPI  =  "tenants" :> (
                   Get '[JSON] [Tenant]
              :<|> Capture "tId" TenantId :> Get '[JSON] Tenant
              :<|> ReqBody '[JSON] Tenant :> Post '[JSON] Tenant
              :<|> Capture "tId" TenantId :> Delete '[JSON] TenantId)

tenantServer :: Server TenantAPI
tenantServer = liftIO getTenants
          :<|> ioMaybeToExceptT err404 . findTenant
          :<|> ioMaybeToExceptT err400 . insertTenant
          :<|> liftIO . deleteTenant
