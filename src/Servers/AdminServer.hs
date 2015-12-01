{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Servers.AdminServer(AdminAPI,adminServer) where

import           Config                   (tokenKey)
import           DB.Admin
import           Domain.Authorization     (Claim (SuperAdmin))
import           Lib.Authorization.Claims (AuthHeader, verifyClaims)
import           Lib.ServantHelpers
import           Servant.API

type AdminAPI = AuthHeader :> ("admin" :> "resetdatabase" :> Get '[JSON] String)

adminServer :: Server AdminAPI
adminServer maybeToken =
              if verifyClaims tokenKey [SuperAdmin] maybeToken
                then liftIO resetDatabase
                else left err401
