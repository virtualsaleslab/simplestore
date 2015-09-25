{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module App.TenantServer(TenantAPI,tenantServer) where

import           Lib.DB.Tenant
import           Lib.ServantHelpers
import           Domain.Models
import           Servant.API
import           Data.Aeson   (FromJSON, ToJSON)

instance ToJSON Tenant
instance FromJSON Tenant

type TenantAPI  =  "tenants" :> (
                   Get '[JSON] Tenants
              :<|> Capture "tId" TenantId :> Get '[JSON] Tenant
              :<|> ReqBody '[JSON] Tenant :> Post '[JSON] Tenant
              :<|> Capture "tId" TenantId :> Delete '[JSON] TenantId)

tenantServer :: Server TenantAPI
tenantServer = liftIO getTenants
          :<|> maybeErr err404 . liftIO . findTenant
          :<|> maybeErr err400 . liftIO . insertTenant
          :<|> liftIO . deleteTenant
