module Lib.Authentication where

import           Domain.Models (IdentityId)

-- TODO: get this from DB/google docs/whatever...
maybeUserIdentity :: String -> String -> Maybe IdentityId
maybeUserIdentity username "pass" =
                    if username `elem` ["tom","yves","marco"]
                      then Just username
                      else Nothing
maybeUserIdentity _ _ = Nothing
