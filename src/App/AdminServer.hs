{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module App.AdminServer(AdminAPI,adminServer) where

import           Lib.DB.Admin
import           Lib.ServantHelpers
import           Servant.API

import           App.AuthServer(verifyClaims,AuthHeader)
import           Lib.Authorization(Claim(SuperAdmin))

type AdminAPI = AuthHeader :> ("admin" :> "builddatabase" :> Get '[JSON] String)

adminServer :: Server AdminAPI
adminServer maybeToken =
              if verifyClaims [SuperAdmin] maybeToken
                then liftIO buildDatabase
                else throwE err401
