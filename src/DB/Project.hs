{-# LANGUAGE OverloadedStrings #-}

module DB.Project(getProjectListForTenant,findProject,insertProject,deleteProject,ProjectListItem(..)) where

import           Config                           (dbName)
import           Database.SQLite.Simple.FromField (fromField)
import           Domain.Models
import           Lib.DB



data ProjectListItem = ProjectListItem
  { projectListItemId          :: ProjectId
  , projectListItemTenantId    :: TenantId
  , projectListItemDescription :: Description
  }
  deriving Show

instance FromRow ProjectListItem where
    fromRow = ProjectListItem <$> field <*> field <*> field

instance FromRow Project where
  fromRow = Project <$> field <*> field <*> field <*> field

findProject' :: Connection -> TenantId -> ProjectId -> IO (Maybe Project)
findProject' conn tId pId = do
  r <- find conn "select id, tenantId, description,content \
                  \from project \
                  \where tenantId = ? \
                  \and id = ?" (tId,pId)
  close conn
  return r


findProject :: TenantId -> ProjectId -> IO (Maybe Project)
findProject tId pId =  do
  conn <- open dbName
  findProject' conn tId pId

insertProject :: Project -> IO (Maybe Project)
insertProject (Project _id tenantId description content) = do
     conn <- open dbName
     execute conn "INSERT INTO project\
                  \(tenantId,description,content) values (?,?,?)"
                  (tenantId, description, content)
     pId  <- lastInsertRowId conn
     findProject' conn tenantId $ fromIntegral pId

deleteProject :: TenantId -> ProjectId -> IO ProjectId
deleteProject tId pId = do
  conn <- open dbName
  execute conn "DELETE FROM project \
                \WHERE tenantId = ? \
                \AND id = ? " [tId,pId]
  close conn
  return pId

getProjectListForTenant :: TenantId -> IO [ProjectListItem]
getProjectListForTenant tId = do
  conn <- open dbName
  t <- query conn "SELECT id,tenantId,description\
                  \ FROM project WHERE tenantId = ?" [tId]
  close conn
  return t
