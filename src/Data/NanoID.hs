{-# LANGUAGE DeriveGeneric #-}

module Data.NanoID where

import           Control.Monad
import           Data.Aeson
import qualified Data.ByteString.Char8 as C
import           Data.Maybe
import           Data.Serialize        (Serialize)
import           Data.Text.Encoding
import           GHC.Generics
import           Numeric.Natural
import           System.Random.MWC

newtype NanoID = NanoID { unNanoID :: C.ByteString } deriving (Eq,Generic)

newtype Alphabet = Alphabet { unAlphabet :: C.ByteString } deriving (Eq)

type Length = Natural

instance Show NanoID where
  show n = C.unpack (unNanoID n)

instance Show Alphabet where
  show a = C.unpack (unAlphabet a)

instance ToJSON NanoID where
  toJSON n = String (decodeUtf8 $ unNanoID n)

instance FromJSON NanoID where
  parseJSON (String s) = pure (NanoID $ encodeUtf8 s)
  parseJSON _          = fail "A JSON String is expected to convert to NanoID"

instance Serialize NanoID

-- | Create a new 'Alphabet' from a string of symbols of your choice
toAlphabet :: String -> Alphabet
toAlphabet = Alphabet . C.pack

-- | Standard 'NanoID' generator function
--
-- >λ: g <- createSystemRandom
-- >λ: NanoID g
-- >x2f8yFadIm-Vp14ByJ8R3
--
nanoID :: GenIO -> IO NanoID
nanoID = customNanoID defaultAlphabet 21

-- | Customable 'NanoID' generator function
customNanoID :: Alphabet  -- ^ An 'Alphabet' of your choice
             -> Length    -- ^ A 'NanoID' length (the standard length is 21 chars)
             -> GenIO     -- ^ The pseudo-random number generator state
             -> IO NanoID
customNanoID a l g =
  NanoID . C.pack <$> replicateM (fromEnum l) ((\r -> C.index ua (r-1)) <$> uniformR (1,al) g)
  where
    ua = unAlphabet a
    al = C.length ua

-- | The default 'Alphabet', made of URL-friendly symbols.
defaultAlphabet :: Alphabet
defaultAlphabet = toAlphabet "ABCDEFGHIJKLMNOPKRSTUVWXYZ_1234567890-abcdefghijklmnopqrstuvwxyz"

-- * Predefined Alphabets borrowed from https://github.com/CyberAP/nanoid-dictionary

numbers :: Alphabet
numbers = toAlphabet "1234567890"

hexadecimalLowercase :: Alphabet
hexadecimalLowercase = toAlphabet "0123456789abcdef"

hexadecimalUppercase :: Alphabet
hexadecimalUppercase = toAlphabet "0123456789ABCDEF"

lowercase :: Alphabet
lowercase = toAlphabet "abcdefghijklmnopqrstuvwxyz"

uppercase :: Alphabet
uppercase = toAlphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

alphanumeric :: Alphabet
alphanumeric = toAlphabet "ABCDEFGHIJKLMNOPKRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz"

nolookalikes :: Alphabet
nolookalikes = toAlphabet "346789ABCDEFGHJKLMNPQRTUVWXYabcdefghijkmnpqrtwxyz"

nolookalikesSafe :: Alphabet
nolookalikesSafe = toAlphabet "6789ABCDEFGHJKLMNPQRTUWYabcdefghijkmnpqrtwyz"

