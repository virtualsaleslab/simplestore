{-# LANGUAGE OverloadedStrings#-}

module GetOpts  where

import Options.Applicative

data ServerOptions = ServerOptions
    { optPort :: Int
    }

serverOptions :: Parser Command
serverOptions = Server . ServerOptions
      <$>  option auto
            ( long "port"
            <> short 'p'
            <> value 8081
            <> metavar "PORT"
            <> help "Port to run the server on"
            )

data ResetDBOptions = ResetDBOptions
    { optResetDBForce :: Bool
    }

resetDatabaseOptions :: Parser Command
resetDatabaseOptions = ResetDB . ResetDBOptions
    <$> switch
       (  long "force"
       <> short 'f'
       <> help  "Force execution of the reset"
       )

data UserOptions = UserOptions
      { optUserNames :: [String]
      }

data UserPassOptions = UserPassOptions
      { optUserPassNames :: [String]
      , optUserPassPasswd :: String
      }

mkUserPassOptions :: Parser Command
mkUserPassOptions = mkuserpass
                  <$> some (argument str (metavar "USERNAMES..."))
                  <*> strOption
                    (  long "password"
                    <> short 'p'
                    <> help "The password to use"
                  )
  where mkuserpass x y = MkUser $ UserPassOptions x y




-- rmUserOptions :: Parser Command
-- rmUserOptions = RmUser . UserOptions <$> some (argument str (metavar "USERNAMES..."))
--
-- passwdUserOptions :: Parser Command
-- passwdUserOptions = PassWdUser . UserOptions <$> some (argument str (metavar "USERNAMES..."))

data QueryOptions = QueryOptions { optQueryString :: String }

-- queryOptions :: Parser QueryOptions
-- queryOptions = QueryOptions <$> argument str $ metavar "QUERY"

data Command = Server ServerOptions
             | ResetDB ResetDBOptions
             | MkUser UserPassOptions
            --  | RmUser UserOptions
            --  | PassWdUser UserOptions

data Options = Options
   { optCommand :: Command
   }

options :: Parser Options
options = Options
    <$> subparser (
        command "server"  (info serverOptions
                          (progDesc "Start a webserver"))
     <> command "resetdb" (info resetDatabaseOptions
                          (progDesc "Reset the server. Use --force to execute"))
     <> command "mkuser"  (info mkUserPassOptions
                          (progDesc "Add one or more users"))
    --  <> command "rmuser"  (info rmUserOptions
    --                       (progDesc "remove one or more users"))
    --  <> command "passwd"  (info passwdUserOptions
    --                       (progDesc "change password for one or more users"))
    )
