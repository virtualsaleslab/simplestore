module GetOpts  where

import Options.Applicative

data Command = ResetDatabase ResetDatabaseOptions
             | Server ServerOptions

data ServerOptions = ServerOptions
    { port :: Int
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

data ResetDatabaseOptions = ResetDatabaseOptions
    { force :: Bool
    }

resetDatabaseOptions :: Parser Command
resetDatabaseOptions = ResetDatabase . ResetDatabaseOptions
    <$> switch
       (  long "force"
       <> short 'f'
       <> help  "Force execution of the reset"
       )

data Options = Options
   { optGlobalDBName :: String
   , optCommand :: Command
   }

options :: Parser Options
options = Options
    <$> strOption
       (   long "dbname"
        <> short 'd'
        <> value "test.db"
        <> help "The filename of the Sqlite database to use"
        <> metavar "DBNAME"
       )
    <*> subparser (
           command "resetdatabase" (info resetDatabaseOptions
             (progDesc "Reset the server. Use --force to execute"))
        <> command "server" (info serverOptions
             (progDesc "Start a webserver"))
        )
