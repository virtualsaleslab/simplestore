{-#LANGUAGE OverloadedStrings #-}

module StorageDB(getTenants,findTenant,insertTenant,deleteTenant,
          getProjectListForTenant,findProject,insertProject,deleteProject,
          buildDatabase) where

import Models
import DB
import Database.SQLite.Simple.FromField(fromField)

dbName = "test.db"

instance FromRow Tenant where
    fromRow = Tenant <$> field <*> field

instance FromRow ProjectListItem where
    fromRow = ProjectListItem <$> field <*> field <*> field

instance FromRow Project where
  fromRow = Project <$> field <*> field <*> field <*> field

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

findTenant :: TenantId -> IO (Maybe Tenant)
findTenant tId = do
  conn <- open dbName
  findTenant' conn tId

insertTenant :: Tenant -> IO (Maybe Tenant)
insertTenant (Tenant _id name) = do
     conn <- open dbName
     execute conn "INSERT INTO tenant(name) values (?)" [name]
     tId <- lastInsertRowId conn
     findTenant' conn $ fromIntegral tId

findTenant' :: Connection -> TenantId -> IO (Maybe Tenant)
findTenant' conn tId = do
  r <- find conn "select * from tenant where id = ?" ( Only tId)
  close conn
  return r

deleteTenant :: TenantId -> IO TenantId
deleteTenant tId = do
  conn <- open dbName
  execute conn "DELETE FROM tenant WHERE id = ? " [tId]
  close conn
  return tId

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

getTenants :: IO [Tenant]
getTenants = do
  conn <- open dbName
  t <- query_ conn "select * from tenant" -- ::IO [Tenant]
  close conn
  return t

getProjectListForTenant :: TenantId -> IO [ProjectListItem]
getProjectListForTenant tId = do
  conn <- open dbName
  t <- query conn "SELECT id,tenantId,description\
                  \ FROM project WHERE tenantId = ?" [tId]
  close conn
  return t
