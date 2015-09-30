{-#LANGUAGE OverloadedStrings #-}

module DB.Tenant(getTenants,findTenant,insertTenant,deleteTenant) where

import Domain.Models
import Lib.DB
import Database.SQLite.Simple.FromField(fromField)

instance FromRow Tenant where
    fromRow = Tenant <$> field <*> field

getTenants :: IO [Tenant]
getTenants = do
  conn <- open dbName
  t <- query_ conn "select id,name from tenant"
  close conn
  return t

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
  r <- find conn "select id,name from tenant where id = ?" ( Only tId)
  close conn
  return r

deleteTenant :: TenantId -> IO TenantId
deleteTenant tId = do
  conn <- open dbName
  execute conn "DELETE FROM tenant WHERE id = ? " [tId]
  close conn
  return tId
