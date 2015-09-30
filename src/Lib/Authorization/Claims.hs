{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}

module Lib.Authorization.Claims(claimsToToken,verifyClaims,maybeTokenToClaims,AuthHeader) where

import           Data.Aeson    (Value (Bool))
import           Data.List     (intersect)
import           Data.Map.Lazy (fromList, toList)
import           Data.Text     (Text, pack, unpack)
import           Servant.API   (Header)
import qualified Web.JWT       as JWT

type AuthHeader = Header "Auth" String

type ClaimsToken = String
type ClaimsTokenSecret = String

verifyClaims :: (Read a, Eq a) => ClaimsTokenSecret -> [a] -> Maybe ClaimsToken -> Bool
verifyClaims tokenKey claims maybeToken =
    claimsContainAtLeastOne claims (maybeTokenToClaims tokenKey maybeToken)
    where
      claimsContainAtLeastOne set items = not . null $ set `intersect` items

claimsToToken :: Show a => ClaimsTokenSecret -> [a] -> ClaimsToken
claimsToToken tokenKey claims = unpack $ JWT.encodeSigned JWT.HS256 key cs
  where
        cs = JWT.def { JWT.iss = JWT.stringOrURI "Foo"
                     , JWT.unregisteredClaims = fromList . map claimToText $ claims
                     }
        key = JWT.secret $ pack tokenKey
        claimToText x = (pack . show $ x , Bool True)

maybeTokenToClaims :: Read a => ClaimsTokenSecret -> Maybe ClaimsToken -> [a]
maybeTokenToClaims _ Nothing = []
maybeTokenToClaims tokenKey (Just token) = case JWT.decodeAndVerifySignature key (pack token) of
    Just verifiedClaims ->
      map textToClaim . toList . JWT.unregisteredClaims . JWT.claims $ verifiedClaims
    Nothing -> []
  where key = JWT.secret $ pack tokenKey
        textToClaim :: Read a => (Text,q) -> a
        textToClaim (x,_)= read $ unpack x
