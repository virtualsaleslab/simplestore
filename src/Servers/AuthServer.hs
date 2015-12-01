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
authServer = ioMaybeToEitherT err401 . return . getToken

-- $ curl http://localhost:8081/auth/token -X POST -H "Content-type: application/json" -d '{"username":"tom","password":"pass"}' -v
-- * Adding handle: conn: 0x5489b8
-- * Adding handle: send: 0
-- * Adding handle: recv: 0
-- * Curl_addHandleToPipeline: length: 1
-- * - Conn 0 (0x5489b8) send_pipe: 1, recv_pipe: 0
-- * About to connect() to localhost port 8081 (#0)
-- *   Trying ::1...
-- * Connection refused
-- *   Trying 127.0.0.1...
-- * Connected to localhost (127.0.0.1) port 8081 (#0)
-- > POST /auth/token HTTP/1.1
-- > User-Agent: curl/7.30.0
-- > Host: localhost:8081
-- > Accept: */*
-- > Content-type: application/json
-- > Content-Length: 36
-- >
-- * upload completely sent off: 36 out of 36 bytes
-- < HTTP/1.1 201 Created
-- < Transfer-Encoding: chunked
-- < Date: Mon, 30 Nov 2015 15:11:44 GMT
-- * Server Warp/3.1.3 is not blacklisted
-- < Server: Warp/3.1.3
-- < Content-Type: application/json
-- <
-- {"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJTdXBlckFkbWluIjp0cnVlLCJpc3MiOiJGb28iLCJQcm9qZWN0Q2xhaW0gUHJvamVjdEVkaXRvciBBbGxQcm9qZWN0c
-- yI6dHJ1ZSwiSWRlbnRpdHlDbGFpbSAxIjp0cnVlLCJUZW5hbnRDbGFpbSBUZW5hbnRBZG1pbiBBbGxUZW5hbnRzIjp0cnVlfQ.DFJtvEPo0aP2H3QfDo844KKBzj44dHShBBg_HN3MXF
-- Y"}* Connection #0 to host localhost left intact
