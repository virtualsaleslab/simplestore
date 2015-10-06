{-# OPTIONS_GHC -fwarn-incomplete-patterns #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main(main) where

import           DB.Admin                 (resetDatabase)
import           DB.Authentication        (changePasswordForUser, createUser,
                                           removeUser)
import           Domain.Models            (userId, userIdentityId)
import           GetOpts
import           Lib.ServantHelpers       (liftIO)
import           Network.Wai              (Application)
import           Network.Wai.Handler.Warp (run)
import           Servant                  (serve)
import           Servers.MainServer

runCommand :: OptionCommand -> IO ()

runCommand (ResetDB force) =
  if force
    then resetDatabase >>= putStrLn
    else putStrLn "Use the --force option if you want this to work"

runCommand (RunServer port) = do
    putStrLn $ "Running webserver on port " ++ show port
    run port $ serve mainAPI mainServer

runCommand (CreateUser usernames pass) =
    mapM_ (liftIO . handleCreateUser) usernames
    where handleCreateUser name =
            createUser name pass >>= putStrLn . status
            where
              status Nothing = "Creation of user " ++ name ++ "failed"
              status (Just usr) = "User " ++ name ++ " created, id = " ++
                                  show (userId usr) ++ ", identityId = " ++
                                  show (userIdentityId usr)

runCommand (RemoveUser userIds) =
    mapM_ (liftIO . handleRemoveUser) userIds
    where handleRemoveUser uId = do
            putStrLn $ "Removing user with id=" ++ show uId
            removeUser uId

runCommand (ChangePass userIds pass) =
  mapM_ (liftIO . handleChangePass) userIds
  where handleChangePass uId = do
          changePasswordForUser uId pass
          putStrLn $ "Changed password for user with id=" ++ show uId

main :: IO ()
main = parseArgsToCommands >>= runCommand
