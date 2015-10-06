{-# LANGUAGE OverloadedStrings #-}

module DB.Admin(resetDatabase) where

import           Config           (dbName)
import           Control.Monad    (when)
import qualified Lib.DB as DB
import           System.Directory (doesFileExist, removeFile)

resetDatabase :: IO String
resetDatabase = do
  fileExists <- doesFileExist dbName
  when fileExists $ removeFile dbName
  conn <- DB.open dbName
  mapM_ (DB.execute_ conn)
    [ "CREATE TABLE IF NOT EXISTS tenant (\
      \id          INTEGER PRIMARY KEY, \
      \name        TEXT NOT NULL UNIQUE)"
    , "CREATE TABLE IF NOT EXISTS project (\
      \id          INTEGER PRIMARY KEY, \
      \tenantId    INTEGER , \
      \description TEXT, \
      \content     TEXT)"
    , "CREATE TABLE IF NOT EXISTS user (\
      \id          INTEGER PRIMARY KEY, \
      \name        TEXT NOT NULL, \
      \passSalt    TEXT, \
      \passHash    TEXT, \
      \identityId  INTEGER)"
    ,"CREATE TABLE IF NOT EXISTS identity (\
      \id          INTEGER PRIMARY KEY, \
      \name        TEXT UNIQUE)"
    ,"CREATE TABLE IF NOT EXISTS claim (\
      \id          INTEGER PRIMARY KEY, \
      \identityId  INTEGER, \
      \name        TEXT, \
      \value       TEXT)"
    ]
  DB.close conn
  return $ "database " ++ dbName ++ " created."
