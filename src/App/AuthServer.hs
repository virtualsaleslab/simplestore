{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleInstances   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}
module App.AuthServer(AuthAPI,authServer) where

import           Control.Monad.Trans.Except (throwE)
import           Data.Aeson
import           Data.ByteString.Char8      (unpack)
import           GHC.Generics               (Generic)
import           Lib.ServantHelpers
import           Servant                    (ServerT, route)
import           Servant.API
import           Servant.Server.Internal    (HasServer, RouteMismatch (..),
                                             Router (..), failWith)

import           Network.HTTP.Types         (status401, status403)
import           Network.Wai                (requestHeaders)



data UserPass = UserPass
  { username:: String
  , password:: String
  } deriving Generic

data AuthProtected

instance HasServer rest => HasServer (AuthProtected :> rest) where
  type ServerT (AuthProtected :> rest) m = ServerT rest m

  route Proxy a = WithRequest $ \ request ->
    route (Proxy :: Proxy rest) $
      case lookup "Auth" (requestHeaders request) of
        Nothing -> return $ failWith $ HttpError status401 (Just "Missing auth header.")
        Just v  -> if isValidToken $ unpack v
            then a
            else return $ failWith $ HttpError status403 (Just "Invalid auth header.")


instance FromJSON UserPass

data Token = Token
    { token :: String
    } deriving Generic

instance ToJSON Token

type AuthAPI = "auth" :> (
                       "logon" :> ReqBody '[JSON] UserPass :> Post '[JSON] Token
                  :<|> "logoff" :>  Header "Auth" String:> Post '[JSON] String
                )

getToken :: UserPass -> Maybe Token
getToken UserPass {username = "Tom", password= "pass"} = Just Token { token="123456"}
getToken _ = Nothing

logOff ::  Maybe String -> Maybe String
logOff (Just "123456") = Just "Succes"
logOff _  = Nothing

isValidToken :: String -> Bool
isValidToken "123456" = True
isValidToken _ = False

authServer :: Server AuthAPI
authServer = maybe (throwE err401) return . getToken
        :<|> maybe (throwE err400) return . logOff
