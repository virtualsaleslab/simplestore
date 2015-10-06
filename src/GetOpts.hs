{-# LANGUAGE OverloadedStrings #-}

module GetOpts  where

import           Domain.Models       (UserId)
import           Options.Applicative

data RunServerOpts  = RunServerOpts  { runServerPort :: Int
                                     }
data ResetDBOpts    = ResetDBOpts    { resetDBForce :: Bool
                                     }
data CreateUserOpts = CreateUserOpts { createUserNames    :: [String]
                                     , createUserPassword :: String
                                     }
data RemoveUserOpts = RemoveUserOpts { removeUserIds :: [UserId]
                                     }
data ChangePassOpts = ChangePassOpts { changePassUserIds  :: [UserId]
                                     , changePassPassword :: String
                                     }

data OptionCommand = RunServer   RunServerOpts
                   | ResetDB     ResetDBOpts
                   | CreateUser  CreateUserOpts
                   | RemoveUser  RemoveUserOpts
                   | ChangePass  ChangePassOpts

data Options = Options { optCommand :: OptionCommand }

parseArgsToCommands :: IO OptionCommand
parseArgsToCommands =  execParser options >>= runOptions
  where
    runOptions (Options cmd)= return cmd
    options =
      info
        ( helper <*> commandOptions )
        (  header "SimpleStorage by arealities.com"
        <> progDesc "A simple multi-tenant storage accessible over HTTP. Run with -h to view available commands\n"
        <> fullDesc
        )
    commandOptions  =
      Options
        <$> subparser (
            defCommand "server"  runServerOpts  "Start a webserver" <>
            defCommand "resetdb" resetDBOpts    "Reset the database" <>
            defCommand "mkuser"  createUserOpts "Add one or more users" <>
            defCommand "rmuser"  removeUserOpts "remove one or more users" <>
            defCommand "passwd"  changePassOpts "change password for one or more users"
            )
    runServerOpts =
      RunServer . RunServerOpts
        <$>  option auto
           (  long "port" <> short 'p'  <> metavar "PORT" <> value 8081
           <> help "Port to run the server on"
           )
    resetDBOpts =
      ResetDB . ResetDBOpts
        <$> switch
          (  long "force" <> short 'f'
          <> help  "Force execution of the reset (required)"
          )
    createUserOpts =
      (\x y -> CreateUser $ CreateUserOpts x y)
        <$> some (argument str (metavar "USERNAMES..."))
        <*> strOption
          (  long "password" <> short 'p' <> metavar "PASSWORD"
          <> help "The password to use (required)"
          )
    removeUserOpts =
      RemoveUser . RemoveUserOpts
        <$> some (argument auto (metavar "USERIDs..."))
    changePassOpts =
      (\x y -> ChangePass $ ChangePassOpts x y)
        <$> some (argument auto (metavar "USERIDs..."))
        <*> strOption
          (  long "password" <> short 'p' <> metavar "PASSWORD"
          <> help "The password to use (required)"
          )
    defCommand cmd what desc = command cmd (info what (progDesc desc))
