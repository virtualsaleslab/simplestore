{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module App.AdminServer(AdminAPI,adminServer) where

import           Lib.DB.Admin
import           Lib.ServantHelpers
import           Servant.API
import           Domain.Authorization     (Claim (SuperAdmin))
import           Lib.Authorization.Claims (AuthHeader, verifyClaims)
import           App.Config               (tokenKey)

type AdminAPI = AuthHeader :> ("admin" :> "builddatabase" :> Get '[JSON] String)

adminServer :: Server AdminAPI
adminServer maybeToken =
              if verifyClaims tokenKey [SuperAdmin] maybeToken
                then liftIO buildDatabase
                else throwE err401
