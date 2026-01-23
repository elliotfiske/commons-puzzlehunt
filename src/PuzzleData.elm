module PuzzleData exposing (password, revealedNumber)

import Types exposing (PuzzleId(..))


{-| The revealed number shown when a puzzle is solved.
This is the single source of truth for the 4-digit safe code.
-}
revealedNumber : PuzzleId -> String
revealedNumber puzzleId =
    case puzzleId of
        Puzzle1 ->
            "7"

        Puzzle2 ->
            "3"

        Puzzle3 ->
            "5"

        Puzzle4 ->
            "7"


{-| The password required to solve each puzzle.
Only used by the backend for validation.
-}
password : PuzzleId -> String
password puzzleId =
    case puzzleId of
        Puzzle1 ->
            "RAISE YOUR SPIRITS"

        Puzzle2 ->
            "COOK THE BOOKS"

        Puzzle3 ->
            "no password for this one"

        Puzzle4 ->
            "LAST CALL"
