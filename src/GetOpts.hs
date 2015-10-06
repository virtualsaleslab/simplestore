{-# LANGUAGE OverloadedStrings #-}

module GetOpts  where

import           Domain.Models       (UserId,Name,Password)
import           Options.Applicative

data OptionCommand = RunServer   { runServerPort :: Int }
                   | ResetDB     { resetDBForce :: Bool }
                   | CreateUser  { createUserNames    :: [Name]
                                 , createUserPassword :: Password }
                   | RemoveUser  { removeUserIds :: [UserId] }
                   | ChangePass  { changePassUserIds  :: [UserId]
                                 , changePassPassword :: Password }
                                 
data Options = Options { optCommand :: OptionCommand }

parseArgsToCommands :: IO OptionCommand
parseArgsToCommands =  execParser options >>= runOptions
  where
    runOptions (Options cmd)= return cmd
    options =
      info
        ( helper <*> commandOptions )
        (  header "\nSimpleStorage by arealities.com\n"
        <> progDesc "A simple multi-tenant storage accessible over HTTP.\n\
                    \Run with -h to view available commands\n"
        <> fullDesc
        )
    commandOptions  =
      Options
        <$> subparser (
            defCommand "server"  runServerOpts  "Start a webserver" <>
            defCommand "resetdb" resetDBOpts    "Reset the database" <>
            defCommand "mkuser"  createUserOpts "Add one or more users" <>
            defCommand "rmuser"  removeUserOpts "Remove users" <>
            defCommand "passwd"  changePassOpts "Change password for users"
            )
    runServerOpts =
      RunServer
        <$>  option auto
           (  long "port" <> short 'p'  <> metavar "PORT" <> value 8081
           <> help "Port to run the server on"
           )
    resetDBOpts =
      ResetDB
        <$> switch
          (  long "force" <> short 'f'
          <> help  "Force execution of the reset (required)"
          )
    createUserOpts =
      CreateUser
        <$> some (argument str (metavar "USERNAMES..."))
        <*> strOption
          (  long "password" <> short 'p' <> metavar "PASSWORD"
          <> help "The password to use (required)"
          )
    removeUserOpts =
      RemoveUser
        <$> some (argument auto (metavar "USERIDs..."))
    changePassOpts =
      ChangePass
        <$> some (argument auto (metavar "USERIDs..."))
        <*> strOption
          (  long "password" <> short 'p' <> metavar "PASSWORD"
          <> help "The password to use (required)"
          )
    defCommand cmd what desc = command cmd (info what (progDesc desc))
