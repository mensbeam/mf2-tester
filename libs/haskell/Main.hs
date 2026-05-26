{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Control.Monad             (unless)
import           Data.Default
import           Data.Aeson.Encode.Pretty  (encodePretty)
import qualified Data.ByteString.Lazy      as BL
import           Data.Microformats2.Parser
import qualified Data.ByteString           as BS
import           Network.URI               (parseURI)
import           System.Environment        (getArgs, getProgName)
import           System.Exit               (exitFailure)
import           System.IO                 (hPutStrLn, stderr)

usage :: IO ()
usage = do
  prog <- getProgName
  hPutStrLn stderr $ "Usage: " <> prog <> " <html-file> <base-url>"
  exitFailure

main :: IO ()
main = do
  args <- getArgs
  unless (length args == 2) usage
  let [htmlFile, rawBaseUrl] = args
  rawBytes <- BS.readFile htmlFile
  let doc     = parseLBS (BL.fromStrict rawBytes)
      rootEl  = documentRoot doc
      settings = def { baseUri = parseURI rawBaseUrl }
      mf2Result = parseMf2 settings rootEl
  BL.putStr (encodePretty mf2Result)
