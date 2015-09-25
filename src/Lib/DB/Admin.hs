{-#LANGUAGE OverloadedStrings #-}

module Lib.DB.Admin(buildDatabase) where

import Domain.Models
import Lib.DB
import Database.SQLite.Simple.FromField(fromField)

buildDatabase :: IO String
buildDatabase = do
  conn <- open dbName
  execute_ conn "CREATE TABLE IF NOT EXISTS tenant (\
                    \id INTEGER PRIMARY KEY, \
                    \name TEXT)"
  execute_ conn "CREATE TABLE IF NOT EXISTS project (\
                    \id INTEGER PRIMARY KEY, \
                    \tenantId INTEGER, \
                    \description TEXT, \
                    \content TEXT)"
  return $ "database " ++ dbName ++ " created."
