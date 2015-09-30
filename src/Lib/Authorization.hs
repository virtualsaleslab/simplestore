module Lib.Authorization where

import Domain.Models(IdentityId,TenantId,ProjectId)

import Data.List(intersect)

data TenantSpec = AllTenants | SpecificTenant TenantId deriving (Eq,Show,Read)
data TenantRole = TenantAdmin deriving (Eq,Show,Read)

data ProjectSpec = AllProjects | AllTenantProjects TenantId | OwnTenantProjects TenantId | SpecificProject ProjectId deriving (Eq,Show,Read)
data ProjectRole = ProjectEditor | ProjectReviewer deriving (Eq,Show,Read)

data Claim = TenantClaim TenantRole TenantSpec
          | ProjectClaim  ProjectRole ProjectSpec
          | IdentityClaim IdentityId
          | OrganisationClaim TenantId
          | SuperAdmin
          deriving (Eq,Show,Read)

aTenantId :: TenantId
aTenantId = 1

anotherTenantId :: TenantId
anotherTenantId = 2

aProjectId :: ProjectId
aProjectId = 3

-- TODO: get this from DB/google docs/whatever...
maybeIdentityToClaims :: Maybe IdentityId -> [Claim]
maybeIdentityToClaims identity =
  case identity of
    Just "tom"   -> [ IdentityClaim "tom"
                    , TenantClaim  TenantAdmin       AllTenants
                    , ProjectClaim ProjectEditor     AllProjects
                    , SuperAdmin
                    ]
    Just "yves"  -> [ IdentityClaim "yves"
                    , ProjectClaim ProjectReviewer $ AllTenantProjects aTenantId
                    ]
    Just "marco" -> [ IdentityClaim "marco"
                    , TenantClaim TenantAdmin      $ SpecificTenant aTenantId
                    , ProjectClaim ProjectEditor   $ OwnTenantProjects aTenantId
                    , ProjectClaim ProjectReviewer $ AllTenantProjects anotherTenantId
                    , ProjectClaim ProjectReviewer $ SpecificProject aProjectId
                    ]
    otherwise    -> []

claimsContainAtLeastOne :: [Claim] -> [Claim] -> Bool
claimsContainAtLeastOne set items = not . null $ set `intersect` items
