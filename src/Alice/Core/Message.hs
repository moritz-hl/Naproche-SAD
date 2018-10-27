{-
Authors: Makarius Wenzel (2018)

Formal output messages, with Prover IDE support.
-}

module Alice.Core.Message (
  trimLine, Kind (..), makeMessage, outputMessage,
  outputReason, outputThesis, outputSimp, outputForTheL
)

where

import Alice.Core.Position


trimLine :: String -> String
trimLine line =
  case reverse line of
    '\n' : '\r' : rest -> reverse rest
    '\n' : rest -> reverse rest
    _ -> line

data Kind = NORMAL | WARNING | ERROR
instance Show Kind where
  show NORMAL = ""
  show WARNING = "Warning"
  show ERROR = "Error"

makeMessage :: String -> Kind -> SourcePos -> String -> String
makeMessage origin kind pos msg =
  (if null origin then "" else "[" ++ origin ++ "] ") ++
  (case show kind of "" -> "" ; s -> s ++ ": ") ++
  (case show pos of "" -> ""; s -> s ++ "\n") ++ msg

outputMessage :: String -> Kind -> SourcePos -> String -> IO ()
outputMessage channel kind pos msg =
  putStrLn $ makeMessage channel kind pos msg

outputReason :: Kind -> SourcePos -> String -> IO ()
outputReason = outputMessage "Reasoner"

outputThesis :: Kind -> SourcePos -> Int -> String -> IO ()
outputThesis kind pos indent msg =
  outputMessage "Thesis" kind pos $ replicate (3 * indent) ' ' ++ msg

outputSimp :: Kind -> SourcePos -> String -> IO ()
outputSimp = outputMessage "Simplifier"

outputForTheL :: Kind -> SourcePos -> String -> IO ()
outputForTheL = outputMessage "ForTheL"
