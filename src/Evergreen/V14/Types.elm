module Evergreen.V14.Types exposing (..)

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
    | HelpRoute
    | DebugResetRoute
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
    }


type PuzzleId
    = Puzzle1
    | Puzzle2
    | Puzzle3


type AnswerResult
    = NoAnswerYet
    | Incorrect PuzzleId
    | Correct PuzzleId String
    | IncorrectButClose PuzzleId


type alias FrontendModel =
    { key : Effect.Browser.Navigation.Key
    , route : Route
    , userProgress : Maybe UserProgress
    , puzzleInput : String
    , lastAnswerResult : AnswerResult
    }


type alias BackendModel =
    { userProgress : SeqDict.SeqDict Effect.Lamdera.SessionId UserProgress
    , sessionClients : SeqDict.SeqDict Effect.Lamdera.SessionId (List Effect.Lamdera.ClientId)
    }


type FrontendMsg
    = UrlClicked Effect.Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | PuzzleInputChanged String
    | SubmitAnswer PuzzleId
    | ClickedBegin
    | NavigateTo String
    | Tick
    | ResetProgress


type ToBackend
    = RequestInitialState
    | MarkIntroSeen
    | SubmitPuzzleAnswer PuzzleId String
    | MarkStashFound StashId
    | ResetAllProgress


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | ClientDisconnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId


type ToFrontend
    = InitialState UserProgress
    | PuzzleAnswerResult PuzzleId (Maybe String)
    | StashMarked StashId
    | ProgressReset
