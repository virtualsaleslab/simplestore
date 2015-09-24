{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module App.ProjectServer(ProjectAPI,projectServer) where

import           Lib.DB.Project
import           Lib.ServantHelpers
import           Models
import           Servant.API

type ProjectAPI  =  "tenants" :> Capture "tId" TenantId :> "projects" :> (
                    Get '[JSON] ProjectList
               :<|> Capture "pId" ProjectId :> Get '[JSON] Project
               :<|> ReqBody '[JSON] Project :> Post '[JSON] Project
               :<|> Capture "pId" ProjectId :> Delete '[JSON] ProjectId )

projectServer :: Server ProjectAPI
projectServer = projectServerForTenant
  where projectServerForTenant tId =
                 liftIO (getProjectListForTenant tId)
            :<|> liftIOMaybeToExceptT err404 . findProject tId
            :<|> liftIOMaybeToExceptT err400 . insertProject
            :<|> liftIO . deleteProject tId
