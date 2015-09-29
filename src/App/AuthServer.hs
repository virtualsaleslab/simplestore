{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module App.AuthServer(AuthAPI,authServer) where

import Lib.ServantHelpers
import Data.Aeson
import           GHC.Generics (Generic)
import Servant.API
import Control.Monad.Trans.Except(throwE)

data UserPass = UserPass
  { username:: String
  , password:: String
  } deriving Generic

instance FromJSON UserPass

data Token = Token {
    token :: String
    } deriving Generic

instance ToJSON Token

type AuthAPI = "auth" :> (
                       "logon" :> ReqBody '[JSON] UserPass :> Put '[JSON] Token
                  :<|> "logoff" :>  Header "Auth" String:> Get '[JSON] String
                )

getToken :: UserPass -> Maybe Token
getToken UserPass {username = "Tom", password= "pass"} = Just Token { token="123456"}
getToken _ = Nothing

logOff ::  Maybe String -> Maybe String
logOff (Just "123456") = Just "Succes"
logOff _  = Nothing

authServer :: Server AuthAPI
authServer = maybe (throwE err401) return . getToken
        :<|> maybe (throwE err400) return . logOff
