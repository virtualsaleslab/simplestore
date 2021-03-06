{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}

module Domain.Models where

import           Domain.Authentication (IdentityId)
import           GHC.Generics          (Generic)

type Name = String
type Password = String
type Description = String
type Content = String
type TenantId = Int
type ProjectId = Int
type UserId = Int

data Tenant = Tenant
  { tenantId   :: TenantId
  , tenantName :: Name
  }
  deriving (Show,Eq,Generic)

data Project = Project
  { projectId          :: ProjectId
  , projectTenantId    :: TenantId
  , projectDescription :: Description
  , projectContent     :: Content
  }
  deriving (Show,Eq,Generic)

data User = User
  { userId           :: UserId
  , userName         :: Name
  , userPasswordSalt :: String
  , userPasswordHash :: String
  , userIdentityId   :: IdentityId
  } deriving Show
