{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeOperators #-}

module App.AdminServer(AdminAPI,adminServer) where

import           Lib.DB.Admin
import           Lib.ServantHelpers
import           Servant.API

type AdminAPI = "admin" :> "builddatabase" :> Get '[JSON] String

adminServer :: Server AdminAPI
adminServer = liftIO buildDatabase
