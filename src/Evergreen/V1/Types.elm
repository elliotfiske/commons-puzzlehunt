module Evergreen.V1.Types exposing (..)

import Effect.Browser
import Effect.Browser.Navigation
import Effect.Lamdera
import SeqDict
import Url


type StashId
    = Moonshine
    | Whiskey
    | Gin
    | Bourbon
    | Rum


type Route
    = IntroRoute
    | HubRoute
    | PaintingsRoute
    | LedgerRoute
    | StashRoute
    | StashFoundRoute StashId
    | TileRoute
    | NotFoundRoute


type alias StashProgress =
    { moonshine : Bool
    , whiskey : Bool
    , gin : Bool
    , bourbon : Bool
    , rum : Bool
    }


type alias UserProgress =
    { hasSeenIntro : Bool
    , puzzle1Complete : Bool
    , puzzle2Complete : Bool
    , puzzle3Stashes : StashProgress
    , puzzle3Complete : Bool
    , puzzle4Complete : Bool
    }


type PuzzleId
    = Puzzle1
    | Puzzle2
    | Puzzle3
    | Puzzle4


type AnswerResult
    = NoAnswerYet
    | Incorrect PuzzleId
    | Correct PuzzleId String


type alias FrontendModel =
    { key : Effect.Browser.Navigation.Key
    , route : Route
    , userProgress : Maybe UserProgress
    , puzzleInput : String
    , lastAnswerResult : AnswerResult
    }


type alias BackendModel =
    { userProgress : SeqDict.SeqDict Effect.Lamdera.SessionId UserProgress
    }


type FrontendMsg
    = UrlClicked Effect.Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | PuzzleInputChanged String
    | SubmitAnswer PuzzleId
    | ClickedBegin
    | NavigateTo String


type ToBackend
    = MarkIntroSeen
    | SubmitPuzzleAnswer PuzzleId String
    | MarkStashFound StashId


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | ClientDisconnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId


type ToFrontend
    = InitialState UserProgress
    | PuzzleAnswerResult PuzzleId (Maybe String)
    | StashMarked StashId
