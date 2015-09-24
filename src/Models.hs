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
  { projectId          :: ProjectId
  , projectTenantId    :: TenantId
  , projectDescription :: Description
  , projectContent     :: Content
  }
  deriving (Show,Eq,Generic)

instance ToJSON Project
instance FromJSON Project

data ProjectListItem = ProjectListItem
  { projectListItemId          :: ProjectId
  , projectListItemTenantId    :: TenantId
  , projectListItemDescription :: Description
  }
  deriving Show

type ProjectList = [ProjectListItem]

instance ToJSON ProjectListItem where
  toJSON(ProjectListItem projectId tenantId description) =
    object [ "projectId"   .= projectId
           , "tentantId"   .= tenantId
           , "description" .= description
           ]
