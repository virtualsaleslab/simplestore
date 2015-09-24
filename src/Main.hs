module Main(main) where

import Network.Wai              (Application)
import Network.Wai.Handler.Warp (run)
import Servant                  (serve)
import StorageServer

app :: Application
app = serve storageAPI storageServer

main :: IO ()
main = run 8081 app
