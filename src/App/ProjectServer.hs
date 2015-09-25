{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module App.ProjectServer(ProjectAPI,projectServer) where

import           Lib.DB.Project
import           Lib.ServantHelpers
import           Domain.Models
import           Servant.API
import           Data.Aeson   (FromJSON, ToJSON, object, toJSON, (.=))

instance ToJSON Project
instance FromJSON Project

instance ToJSON ProjectListItem where
  toJSON(ProjectListItem projectId tenantId description) =
    object [ "projectId"   .= projectId
           , "tentantId"   .= tenantId
           , "description" .= description
           ]

type ProjectAPI  =  "tenants" :> Capture "tId" TenantId :> "projects" :> (
                    Get '[JSON] ProjectList
               :<|> Capture "pId" ProjectId :> Get '[JSON] Project
               :<|> ReqBody '[JSON] Project :> Post '[JSON] Project
               :<|> Capture "pId" ProjectId :> Delete '[JSON] ProjectId )

projectServer :: Server ProjectAPI
projectServer = projectServerForTenant
  where projectServerForTenant tId =
                 liftIO (getProjectListForTenant tId)
            :<|> maybeErr err404 . findProject tId
            :<|> maybeErr err400 . insertProject
            :<|> liftIO . deleteProject tId