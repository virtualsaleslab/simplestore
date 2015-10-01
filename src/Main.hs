module Main(main) where

import Network.Wai              (Application)
import Network.Wai.Handler.Warp (run)
import Servant                  (serve)
import Servers.MainServer
import Lib.ServantHelpers(liftIO)

import GetOpts
import Options.Applicative

import DB.Admin(resetDatabase)
import DB.Authentication(createUser)

import Domain.Models(userId,userIdentityId)

runServer :: ServerOptions -> Options -> IO ()
runServer opt gOpt = do
    let p = optPort opt
    putStrLn $ "Running webserver on port " ++ show p
    run p $ serve mainAPI mainServer

runResetDB :: ResetDBOptions -> Options -> IO ()
runResetDB opts gOpts = if optResetDBForce opts
    then resetDatabase >>= putStrLn
    else putStrLn "Use the --force option if you want this to work"

runMkUser :: UserPassOptions -> Options -> IO ()
runMkUser opts gOpts = mapM_ (liftIO . createuser) $ optUserPassNames opts
  where
      pass = optUserPassPasswd opts
      createuser name = do
          u <- createUser name pass
          putStrLn $ case u of
            Nothing -> "Creation of user " ++ name ++ "failed"
            Just u -> mconcat
                        [ "User "
                        , name
                        ," created, id = "
                        , show (userId u)
                        ,", identityId = "
                        , show (userIdentityId u)
                        ]



runCommand :: Options -> IO ()
runCommand opts = case optCommand opts of
  Server     x -> runServer     x opts
  ResetDB    x -> runResetDB    x opts
  MkUser     x -> runMkUser     x opts
  -- RmUser     x -> runRmUser     x opts
  -- PassWdUser x -> runPasswdUser x opts

main :: IO ()
main = execParser opts >>= runCommand
  where opts = info ( helper <*> options )
                (  header "SimpleStorage by arealities.com"
                <> progDesc "A simple multi-tenant database accessible over HTTP. Run with -h to view available commands\n"
                <> fullDesc
                )
