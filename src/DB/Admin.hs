{-# LANGUAGE OverloadedStrings #-}

module DB.Admin(resetDatabase) where

import           Config (dbName)
import           Lib.DB
import System.Directory(doesFileExist,removeFile)
import Control.Monad(when)

resetDatabase :: IO String
resetDatabase = do
  fileExists <- doesFileExist dbName
  when fileExists $ removeFile dbName
  conn <- open dbName
  execute_ conn "CREATE TABLE IF NOT EXISTS tenant (\
                    \id          INTEGER PRIMARY KEY, \
                    \name        TEXT NOT NULL UNIQUE)"
  execute_ conn "CREATE TABLE IF NOT EXISTS project (\
                    \id          INTEGER PRIMARY KEY, \
                    \tenantId    INTEGER , \
                    \description TEXT, \
                    \content     TEXT)"
  execute_ conn "CREATE TABLE IF NOT EXISTS user (\
                    \id          INTEGER PRIMARY KEY, \
                    \name        TEXT NOT NULL, \
                    \passSalt    TEXT, \
                    \passHash    TEXT, \
                    \identityId  INTEGER)"
  execute_ conn "CREATE TABLE IF NOT EXISTS identity (\
                    \id          INTEGER PRIMARY KEY, \
                    \name        TEXT UNIQUE)"
  execute_ conn "CREATE TABLE IF NOT EXISTS claim (\
                    \id          INTEGER PRIMARY KEY, \
                    \identityId  INTEGER, \
                    \name        TEXT, \
                    \value       TEXT)"
  return $ "database " ++ dbName ++ " created."
