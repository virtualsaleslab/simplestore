{-# LANGUAGE OverloadedStrings #-}

module DB.Authentication where

import           Config                           (dbName)
import           Database.SQLite.Simple.FromField (fromField)
import           Domain.Authentication            (IdentityId, hashPwd, verifyPwd)
import           Domain.Models                    (User (..), UserId(..),userIdentityId)
import           Lib.DB
import           Control.Monad.IO.Class(liftIO)
import Data.Functor(void)


instance FromRow User where
    fromRow = User <$> field <*> field <*> field <*> field <*> field

-- TODO: get this from DB/google docs/whatever...
maybeUserIdentity :: String -> String -> IO (Maybe IdentityId)
maybeUserIdentity username pass = do
  user <- findUserByCredentials username pass
  return $ userIdentityId <$> user

-- TODO : proper salting + hashing of passwords
createUser :: String -> String -> IO (Maybe User)
createUser name pass = do
    hashed <- hashPwd pass
    insertUser $ User 1 name hashed "salt" 1

removeUser :: UserId -> IO ()
removeUser userId = do
      conn <- open dbName
      findUser' conn userId >>= deleteFromDb conn >> close conn
      where deleteFromDb conn (Just usr) =
              execute conn "DELETE FROM identity WHERE id = ?;\
                           \DELETE FROM user WHERE id = ?" (userIdentityId usr, userId)
            deleteFromDb _ _ = return ()

changePasswordForUser :: UserId -> String -> IO ()
changePasswordForUser userId pass = do
    hashed <- hashPwd pass
    let salt = "salt" :: String
    conn <- open dbName
    execute conn "UPDATE user SET passHash = ?, passSalt = ? WHERE id = ?" (hashed, salt, userId)
    close conn

insertUser :: User -> IO (Maybe User)
insertUser (User _id name passSalt passHash identity) = do
     conn <- open dbName
     execute conn "INSERT INTO identity\
                  \(name) values (?)" [name]
     iId  <- lastInsertRowId conn
     execute conn "INSERT INTO user\
                  \(name,passSalt,passHash,identityId) values (?,?,?,?)"
                  (name,passHash,passSalt,iId)
     uId  <- lastInsertRowId conn
     findUser' conn $ fromIntegral uId

findUser' :: Connection -> UserId -> IO (Maybe User)
findUser' conn uId = do
  r <- find conn "select id, name, passSalt, passHash, identityId \
                 \from user \
                 \where id = ?" [uId]
  close conn
  return r

findUser :: UserId -> IO (Maybe User)
findUser uId = do
  conn <- open dbName
  findUser' conn uId

findUserByCredentials :: String -> String -> IO (Maybe User)
findUserByCredentials name password = do
  conn <- open dbName
  user <- findUserByName conn name
  return (validate user password)

validate :: Maybe User -> String -> Maybe User
validate user password = do
  user' <- user
  let isCorrectPassword = verifyPwd (userPasswordHash user') password
  if isCorrectPassword then user else Nothing

findUserByName :: Connection -> String -> IO (Maybe User)
findUserByName conn name = do
  r <- find conn "select id, name, passSalt, passHash, identityId \
                 \from user \
                 \where name = ?" [name]
  close conn
  return r
