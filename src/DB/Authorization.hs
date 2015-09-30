module DB.Authorization where

import Domain.Authentication
import Domain.Authorization

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
  where
      aTenantId = 1
      anotherTenantId = 2
      aProjectId = 3
