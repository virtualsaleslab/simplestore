{-# LANGUAGE OverloadedStrings #-}

module DB.Authentication where

import           Config                           (dbName)
import           Database.SQLite.Simple.FromField (fromField)
import           Domain.Authentication            (IdentityId)
import           Domain.Models                    (User (..), UserId)
import           Lib.DB


instance FromRow User where
    fromRow = User <$> field <*> field <*> field <*> field <*> field

-- TODO: get this from DB/google docs/whatever...
maybeUserIdentity :: String -> String -> Maybe IdentityId
maybeUserIdentity username "pass" =
                    if username `elem` ["tom","yves","marco"]
                      then Just 1
                      else Nothing
maybeUserIdentity _ _ = Nothing


-- TODO : proper salting + hashing of passwords
createUser :: String -> String -> IO (Maybe User)
createUser name pass =
    insertUser $ User 1 name pass "salt" 1

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
