{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Servers.ProjectServer(ProjectAPI,projectServer,ioMaybeToEitherT) where

import           Data.Aeson         (FromJSON, ToJSON, object, toJSON, (.=))
import           DB.Project
import           Domain.Models
import           Lib.ServantHelpers
import           Servant.API

instance ToJSON Project
instance FromJSON Project

instance ToJSON ProjectListItem where
  toJSON(ProjectListItem projectId tenantId description) =
    object [ "projectId"   .= projectId
           , "tentantId"   .= tenantId
           , "description" .= description
           ]

type ProjectAPI  =  "tenants" :> Capture "tId" TenantId :> "projects" :> (
                    Get '[JSON] [ProjectListItem]
               :<|> Capture "pId" ProjectId :> Get '[JSON] Project
               :<|> ReqBody '[JSON] Project :> Post '[JSON] Project
               :<|> Capture "pId" ProjectId :> Delete '[JSON] ProjectId
               )


projectServer :: Server ProjectAPI
projectServer = projectServerForTenant
  where projectServerForTenant tId =
                 liftIO (getProjectListForTenant tId)
            :<|> ioMaybeToEitherT err404 . findProject tId
            :<|> ioMaybeToEitherT err400 . insertProject
            :<|> liftIO . deleteProject tId
