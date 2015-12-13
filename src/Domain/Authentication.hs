module Domain.Authentication where

import           Crypto.PasswordStore
import qualified Data.ByteString.Char8 as B


type IdentityId = Int

-- Your strength value should not be less than 16, and 17 is a good default
-- value at the time of this writing, in 2014. OWASP suggests adding 1 to the
-- strength every two years. https://hackage.haskell.org/package/pwstore-fast-2.4.4/docs/Crypto-PasswordStore.html
strength = 17

hashPwd :: String -> IO String
hashPwd textPassword = B.unpack <$> makePassword (B.pack textPassword) strength

verifyPwd :: String -> String -> Bool
verifyPwd hashed attempt = verifyPassword (B.pack attempt) (B.pack hashed)
