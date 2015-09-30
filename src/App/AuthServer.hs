{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleInstances   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}

module App.AuthServer(AuthAPI,authServer,AuthHeader,verifyClaims) where

import           Control.Monad.Trans.Except (ExceptT, throwE)
import           Data.Aeson
import           GHC.Generics               (Generic)
import           Lib.ServantHelpers
import           Servant                    (ServerT, ServantErr)
import           Servant.API
import  Control.Monad.IO.Class

import qualified Web.JWT as  JWT
import Data.Text(Text,pack,unpack)

import Lib.Authentication;
import Lib.Authorization;

import Data.Map.Lazy(fromList,toList)



data User = User
  { username:: String
  , password:: String
  } deriving Generic

instance FromJSON User

data Token = Token
    { token :: Data.Text.Text
    } deriving Generic

instance ToJSON Token

type AuthHeader =  Header "Auth" String

type AuthAPI = "auth" :> (
                       "token" :> ReqBody '[JSON] User :> Post '[JSON] Token
                )

getToken :: User -> Maybe Token
getToken User {username = u, password= p} =
    case claims of
      [] -> Nothing
      x -> Just . claimsToToken $ claims
    where claims = maybeIdentityToClaims $ maybeUserIdentity u p

authServer :: Server AuthAPI
authServer = ioMaybeToExceptT err401 . return . getToken

tokenKey :: Text
tokenKey = "secret-key"

verifyClaims :: [Claim] -> Maybe String -> Bool
verifyClaims claims maybeToken = claimsContainAtLeastOne claims (maybeTokenToClaims maybeToken)

claimsToToken :: [Claim] -> Token
claimsToToken claims = Token {token = encodedClaims}
  where encodedClaims = JWT.encodeSigned JWT.HS256 key cs
        cs = JWT.def { JWT.iss = JWT.stringOrURI "Foo"
                     , JWT.unregisteredClaims = fromList . map claimToText $ claims
                     }
        key = JWT.secret tokenKey
        claimToText x = (pack . show $ x ,Bool True)

maybeTokenToClaims :: Maybe String -> [Claim]
maybeTokenToClaims Nothing = []
maybeTokenToClaims (Just token) = case JWT.decodeAndVerifySignature key (pack token) of
    Just verifiedClaims ->
      map textToClaim . toList . JWT.unregisteredClaims . JWT.claims $ verifiedClaims
    Nothing -> []
  where key = JWT.secret tokenKey
        textToClaim :: (Text,a) -> Claim
        textToClaim (x,_)= read $ unpack x
