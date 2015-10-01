module Main(main) where

import Network.Wai              (Application)
import Network.Wai.Handler.Warp (run)
import Servant                  (serve)
import Servers.MainServer

app :: Application
app = serve mainAPI mainServer

main :: IO ()
main = run 8081 app
