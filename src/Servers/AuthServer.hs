{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Servers.AuthServer(AuthAPI,authServer) where

import           Config                   (tokenKey)
import           Data.Aeson
import           DB.Authentication        (maybeUserIdentity)
import           DB.Authorization         (maybeIdentityToClaims)
import           GHC.Generics             (Generic)
import           Lib.Authorization.Claims (claimsToToken)
import           Lib.ServantHelpers
import           Servant.API

data User = User
  { username:: String
  , password:: String
  } deriving Generic

instance FromJSON User

data Token = Token
    { token :: String
    } deriving Generic

instance ToJSON Token

type AuthAPI = "auth" :> "token" :> ReqBody '[JSON] User :> Post '[JSON] Token

getToken :: User -> Maybe Token
getToken User {username = u, password= p} =
    case claims of
      [] -> Nothing
      x -> Just . Token $ claimsToToken tokenKey claims
    where claims = maybeIdentityToClaims $ maybeUserIdentity u p

authServer :: Server AuthAPI
authServer = ioMaybeToExceptT err401 . return . getToken