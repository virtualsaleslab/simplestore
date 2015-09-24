{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module StorageServer where

import           Models
import           Servant.API
import           ServantHelpers
import           StorageDB

type TenantAPI  =  Get '[JSON] Tenants
              :<|> Capture "tId" TenantId :> Get '[JSON] Tenant
              :<|> ReqBody '[JSON] Tenant :> Post '[JSON] Tenant
              :<|> Capture "tId" TenantId :> Delete '[JSON] TenantId

type ProjectAPI  =  Get '[JSON] ProjectList
               :<|> Capture "pId" ProjectId :> Get '[JSON] Project
               :<|> ReqBody '[JSON] Project :> Post '[JSON] Project
               :<|> Capture "pId" ProjectId :> Delete '[JSON] ProjectId

type AdminAPI = "builddatabase" :> Get '[JSON] String

type StorageAPI =  "tenants" :> TenantAPI
              :<|> "tenants" :> Capture "tId" TenantId :> "projects" :> ProjectAPI
              :<|> "admin"   :> AdminAPI

tenantServer :: Server TenantAPI
tenantServer = liftIO getTenants
          :<|> liftIOMaybeToExceptT err404 . findTenant
          :<|> liftIOMaybeToExceptT err400 . insertTenant
          :<|> liftIO . deleteTenant

projectServer :: TenantId -> Server ProjectAPI
projectServer tId =  liftIO (getProjectListForTenant tId)
                :<|> liftIOMaybeToExceptT err404 . findProject tId
                :<|> liftIOMaybeToExceptT err400 . insertProject
                :<|> liftIO . deleteProject tId

adminServer :: Server AdminAPI
adminServer = liftIO buildDatabase

storageAPI :: Proxy StorageAPI
storageAPI = Proxy

storageServer :: Server StorageAPI
storageServer = tenantServer
           :<|> projectServer
           :<|> adminServer


-- $ curl -H "Content-Type: application/json" -X POST -d '{"tenantId":1,"tenantName":"facebook"}' http://localhost:8081/tenants/
-- {"tenantName":"facebook","tenantId":2}
-- $ curl -H "Content-Type: application/json" -X POST -d '{"projectId":1,"projectTenantId":1,"projectDescription":"a project","projectContent"
-- :"some value"}' http://localhost:8081/tenants/1/projects
-- {"projectTenantId":1,"projectContent":"some value","projectId":1,"projectDescription":"a project"}
