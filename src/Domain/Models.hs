{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}

module Domain.Models where

import           GHC.Generics (Generic)

type Name = String
type Description = String
type Content = String
type TenantId = Int
type ProjectId = Int

type IdentityId = String

data Tenant = Tenant
  { tenantId   :: TenantId
  , tenantName :: Name
  }
  deriving (Show,Eq,Generic)

type Tenants = [Tenant]

data Project = Project
  { projectId          :: ProjectId
  , projectTenantId    :: TenantId
  , projectDescription :: Description
  , projectContent     :: Content
  }
  deriving (Show,Eq,Generic)


data ProjectListItem = ProjectListItem
  { projectListItemId          :: ProjectId
  , projectListItemTenantId    :: TenantId
  , projectListItemDescription :: Description
  }
  deriving Show

type ProjectList = [ProjectListItem]
