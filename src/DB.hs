{-# LANGUAGE OverloadedStrings #-}

module DB(open,close,query_,query,execute_,execute,lastInsertRowId
        ,find,FromRow,fromRow, field,Connection,Only(..)) where

import           Database.SQLite.Simple
import           Database.SQLite.Simple.FromField (FromField)
import           Control.Monad.IO.Class(liftIO)

find:: (ToRow a, FromRow b) => Connection -> Query -> a -> IO (Maybe b)
find conn sql pars = do
  rows <- query conn sql pars
  case rows of
    [] -> return Nothing
    [x] -> return $ Just x
