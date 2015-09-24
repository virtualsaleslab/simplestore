{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}

module Models where

import           Data.Aeson   (FromJSON, ToJSON, object, toJSON, (.=))
import           GHC.Generics (Generic)

type Name = String
type Description = String
type Content = String
type TenantId = Int
type ProjectId = Int

data Tenant = Tenant
  { tenantId   :: TenantId
  , tenantName :: Name
  }
  deriving (Show,Eq,Generic)

instance ToJSON Tenant
instance FromJSON Tenant

type Tenants = [Tenant]

data Project = Project
  { projectTenantId    :: TenantId
  , projectId          :: ProjectId
  , projectDescription :: Description
  , projectContent     :: Content
  }
  deriving (Show,Eq,Generic)

instance ToJSON Project
instance FromJSON Project

data ProjectListItem = ProjectListItem
  { projectListItemTenantId    :: TenantId
  , projectListItemId          :: ProjectId
  , projectListItemDescription :: Description
  }
  deriving Show

type ProjectList = [ProjectListItem]

instance ToJSON ProjectListItem where
  toJSON(ProjectListItem tenantId projectId description) =
    object [ "tentantId"   .= tenantId
           , "projectId"   .= projectId
           , "description" .= description
           ]
