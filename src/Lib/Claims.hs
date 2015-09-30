module Lib.Claims where

import Web.JWT
import Domain.Models
import Data.List(intersect)

type IdentityId = String

data TenantSpec = AllTenants | SpecificTenant TenantId deriving Eq
data TenantRole = TenantAdmin deriving Eq

data ProjectSpec = AllProjects | AllTenantProjects TenantId | OwnTenantProjects TenantId | SpecificProject ProjectId deriving Eq
data ProjectRole = ProjectEditor | ProjectReviewer deriving Eq

data Claim = TenantClaim TenantRole TenantSpec
          | ProjectClaim  ProjectRole ProjectSpec
          deriving Eq

aTenantId :: TenantId
aTenantId = 1

anotherTenantId :: TenantId
anotherTenantId = 2

aProjectId :: ProjectId
aProjectId = 3



-- TODO: get this from DB/google docs/whatever...
maybeUserIdentity :: String -> String -> Maybe IdentityId
maybeUserIdentity username "pass" =
                    if username `elem` ["tom","yves","marco"]
                      then Just username
                      else Nothing
maybeUserIdentity _ _ = Nothing


-- TODO: get this from DB/google docs/whatever...
maybeIdentityToClaims :: Maybe IdentityId -> [Claim]
maybeIdentityToClaims identity =
  case identity of
    Just "tom"   -> [ TenantClaim  TenantAdmin       AllTenants
                    , ProjectClaim ProjectEditor     AllProjects
                    ]
    Just "yves"  -> [ ProjectClaim ProjectReviewer $ AllTenantProjects aTenantId
                    ]
    Just "marco" -> [ TenantClaim TenantAdmin      $ SpecificTenant aTenantId
                    , ProjectClaim ProjectEditor   $ OwnTenantProjects aTenantId
                    , ProjectClaim ProjectReviewer $ AllTenantProjects anotherTenantId
                    , ProjectClaim ProjectReviewer $ SpecificProject aProjectId
                    ]
    otherwise    -> []

claimsContainAtLeastOne :: [Claim] -> [Claim] -> Bool
claimsContainAtLeastOne set items = null $ set `intersect` items
