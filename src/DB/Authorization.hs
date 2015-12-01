module DB.Authorization where

import           Domain.Authentication
import           Domain.Authorization

-- TODO: get this from DB/google docs/whatever...
maybeIdentityToClaims :: Maybe IdentityId -> IO [Claim]
maybeIdentityToClaims identity = return $
  case identity of
    Just 1   ->
      [ IdentityClaim 1
      , TenantClaim  TenantAdmin       AllTenants
      , ProjectClaim ProjectEditor     AllProjects
      , SuperAdmin
      ]
    Just 2  ->
      [ IdentityClaim 2
      , ProjectClaim ProjectReviewer $ AllTenantProjects aTenantId
      ]
    Just 3 ->
      [ IdentityClaim 3
      , TenantClaim TenantAdmin      $ SpecificTenant aTenantId
      , ProjectClaim ProjectEditor   $ OwnTenantProjects aTenantId
      , ProjectClaim ProjectReviewer $ AllTenantProjects anotherTenantId
      , ProjectClaim ProjectReviewer $ SpecificProject aProjectId
      ]
    otherwise    -> []
  where
      aTenantId = 1
      anotherTenantId = 2
      aProjectId = 3
