module Main(main) where

import Network.Wai              (Application)
import Network.Wai.Handler.Warp (run)
import Servant                  (serve)
import Servers.MainServer

import GetOpts
import Options.Applicative
import Lib.ServantHelpers(liftIO)

import DB.Admin(buildDatabase)

runServer :: ServerOptions -> Options -> IO ()
runServer opt gOpt = do
    let p = port opt
    putStrLn $ "Running webserver on port " ++ show p
    run p $ serve mainAPI mainServer

runResetDB :: ResetDatabaseOptions -> Options -> IO ()
runResetDB opts gOpts = if force opts
    then buildDatabase >>= putStrLn
    else putStrLn "Use the --force option if you want this to work"

runCommand :: Options -> IO ()
runCommand opts = case optCommand opts of
  Server        x -> runServer x opts
  ResetDatabase x -> runResetDB x opts

main :: IO ()
main = execParser opts >>= runCommand
  where opts = info ( helper <*> options )
                (  header "SimpleStorage by arealities.com"
                <> progDesc "A simple multi-tenant database accessible over HTTP. Run with -h to view available commands\n"
                <> fullDesc
                )
