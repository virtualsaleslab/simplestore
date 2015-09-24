{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module StorageServer where

import           Models
import           Servant.API
import           ServantHelpers
import           StorageDB

type ProjectAPI  =  Get '[JSON] ProjectList
               :<|> Capture "pId" ProjectId :> Get '[JSON] Project
               :<|> ReqBody '[JSON] Project :> Post '[JSON] Project
               :<|> Capture "pId" ProjectId :> Delete '[JSON] ProjectId

type TenantAPI  =  Capture "tId" TenantId :> "projects" :> ProjectAPI
              :<|> Get '[JSON] Tenants
              :<|> Capture "tId" TenantId :> Get '[JSON] Tenant
              :<|> ReqBody '[JSON] Tenant :> Post '[JSON] Tenant
              :<|> Capture "tId" TenantId :> Delete '[JSON] TenantId

type AdminAPI = "builddatabase" :> Get '[JSON] String

type StorageAPI =  "tenants" :> TenantAPI
              :<|> "admin"   :> AdminAPI

projectServer :: TenantId -> Server ProjectAPI
projectServer tId =
               liftIO (getProjectListForTenant tId)
          :<|> liftIOMaybeToEither err404 . findProject tId
          :<|> liftIOMaybeToEither err400 . insertProject
          :<|> liftIO . deleteProject tId

tenantServer :: Server TenantAPI
tenantServer = projectServer
          :<|> liftIO getTenants
          :<|> liftIOMaybeToEither err404 . findTenant
          :<|> liftIOMaybeToEither err400 . insertTenant
          :<|> liftIO . deleteTenant

adminServer :: Server AdminAPI
adminServer = liftIO buildDatabase

storageAPI :: Proxy StorageAPI
storageAPI = Proxy

storageServer :: Server StorageAPI
storageServer = tenantServer :<|> adminServer


-- $ curl -H "Content-Type: application/json" -X POST -d '{"tenantId":1,"tenantName":"facebook"}' http://localhost:8081/tenants/
-- {"tenantName":"facebook","tenantId":2}
-- $ curl -H "Content-Type: application/json" -X POST -d '{"projectId":1,"projectTenantId":1,"projectDescription":"a project","projectContent"
-- :"some value"}' http://localhost:8081/tenants/1/projects
-- {"projectTenantId":1,"projectContent":"some value","projectId":1,"projectDescription":"a project"}
