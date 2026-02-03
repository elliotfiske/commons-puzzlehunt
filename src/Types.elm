module Types exposing
    ( AnswerResult(..)
    , BackendModel
    , BackendMsg(..)
    , FrontendModel
    , FrontendMsg(..)
    , PuzzleId(..)
    , Route(..)
    , StashId(..)
    , StashProgress
    , ToBackend(..)
    , ToFrontend(..)
    , UserProgress
    )

import Effect.Browser
import Effect.Browser.Navigation
import Effect.Lamdera
import SeqDict exposing (SeqDict)
import Url


type Route
    = IntroRoute
    | HubRoute
    | PaintingsRoute
    | LedgerRoute
    | StashRoute
    | StashFoundRoute StashId
    | HelpRoute
    | NotFoundRoute


type PuzzleId
    = Puzzle1
    | Puzzle2
    | Puzzle3


type StashId
    = Moonshine
    | Whiskey
    | Gin
    | Bourbon
    | Rum


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
    { userProgress : SeqDict Effect.Lamdera.SessionId UserProgress
    , sessionClients : SeqDict Effect.Lamdera.SessionId (List Effect.Lamdera.ClientId)
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


type ToBackend
    = RequestInitialState
    | MarkIntroSeen
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
