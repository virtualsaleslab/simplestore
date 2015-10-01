{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Servers.AdminServer(AdminAPI,adminServer) where

import           DB.Admin
import           Lib.ServantHelpers
import           Servant.API
import           Domain.Authorization     (Claim (SuperAdmin))
import           Lib.Authorization.Claims (AuthHeader, verifyClaims)
import           Config               (tokenKey)

type AdminAPI = AuthHeader :> ("admin" :> "resetdatabase" :> Get '[JSON] String)

adminServer :: Server AdminAPI
adminServer maybeToken =
              if verifyClaims tokenKey [SuperAdmin] maybeToken
                then liftIO resetDatabase
                else throwE err401
