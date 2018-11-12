{-
Authors: Steffen Frerix (2017 - 2018)

Primitive parsers.
-}



module Alice.Parser.Primitives where

import Alice.Parser.Base
import Alice.Parser.Error
import Alice.Parser.Token
import Alice.Core.Position

import Data.List (uncons)
import Data.Char (isAlpha, toLower)
import Control.Monad (void, guard)


-- primitive Token operations

---- parse the current token
tokenPrim :: (Token -> Maybe a) -> Parser st a
tokenPrim test = Parser $ \(State st input _) ok _ eerr ->
  case uncons input of
    Nothing     -> eerr $ unexpectError "" noPos
    Just (t,ts) -> case guard (not $ isEOF t) >> test t of
      Just x  ->
        let newstate = State st ts (tokenPos t)
            newerr   = newErrorUnknown $ tokenPos t
        in  seq newstate $ ok newerr [] . pure $ PR x newstate
      Nothing -> eerr $ unexpectError (showToken t) (tokenPos t)

---- parse end of input
eof :: Parser st ()
eof = Parser $ \(State st input _) ok _ eerr ->
  case uncons input of
    Nothing -> eerr $ unexpectError "" noPos
    Just (t, ts) ->
      if isEOF t
      then
        let newstate = State st ts (tokenPos t)
            newerr   = newErrorUnknown $ tokenPos t
        in  seq newstate $ ok newerr [] . pure $ PR () newstate
      else eerr $ unexpectError (showToken t) (tokenPos t)


-- useful macros

---- check if the current token satisfies a predicate; if not fail
satisfy :: (String -> Bool) -> Parser st String
satisfy pr = tokenPrim prTest
  where
    prTest tk = let s = showToken tk in guard (pr s) >> return s

---- check if the current token is a word
word :: Parser st String
word = satisfy $ \tk -> all isAlpha tk

---- check if the current token is equal to s after mapping to lowercase
{-# INLINE wdToken #-}
wdToken :: String -> Parser st ()
wdToken s = void $ satisfy $ \tk -> s == map toLower tk

---- check if the current token is equal to some element of ls after
---- mapping to lowercase
{-# INLINE wdTokenOf #-}
wdTokenOf :: [String] -> Parser st ()
wdTokenOf ls = void $ satisfy $ \tk -> map toLower tk `elem` ls

---- check if the current token is equal to s respecting case
{-# INLINE smTokenOf #-}
smTokenOf :: String -> Parser st ()
smTokenOf s = void $ satisfy $ \tk -> s == tk

---- check if the next tokens form a given symbol
symbol :: String -> Parser st ()
symbol []     = return ()
symbol (c:cs) = smTokenOf [c] >> symbol cs

---- always succeed and pass on the string of the token
anyToken :: Parser st String
anyToken = tokenPrim (Just . showToken)
