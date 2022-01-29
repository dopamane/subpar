{-|
Module      : Subpar
Description : SMT interface
Copyright   : (c) David Cox 2022
License     : BSD-3-Clause
Maintainer  : dwc1295@gmail.com
-}
module Subpar (

  -- * Process
  module Subpar.Process,

  -- * Transmit
  transmit,
  transmit_,

  -- ** Low-level interface
  send,
  recv,

  -- * Syntax
  module Subpar.Syntax

) where

import Control.Monad (forM)
import Data.Attoparsec.Text (Result, parseWith)
import Data.Text (Text)
import qualified Data.Text    as T
import qualified Data.Text.IO as TIO

import Subpar.Process
import Subpar.Syntax

-- | Send 'Command's and receive 'GeneralResponse's.
transmit :: SmtHandle -> [Command] -> IO [Result GeneralResponse]
transmit hndl cmds = forM cmds $ \cmd -> do
  send hndl $ unparseCommand cmd
  parseWith (recv hndl) parseGeneralResponse =<< (recv hndl)

-- | Send 'Command's without receiving 'GeneralResponse's.
transmit_ :: SmtHandle -> [Command] -> IO ()
transmit_ hndl = mapM_ (send hndl . unparseCommand)

-- | Send line of 'Text' to 'SmtHandle'. See 'transmit' and 'transmit_'.
send :: SmtHandle -> Text -> IO ()
send hndl = TIO.hPutStrLn (smtIn hndl)

-- | Receive line of 'Text' from 'SmtHandle'. See 'transmit'.
recv :: SmtHandle -> IO Text
recv = TIO.hGetLine . smtOut