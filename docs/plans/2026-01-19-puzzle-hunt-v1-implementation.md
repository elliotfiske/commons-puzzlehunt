# Puzzle Hunt v1 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a functional puzzle hunt website with intro screen, hub, 4 puzzles, and session-based progress tracking.

**Architecture:** Lamdera app with frontend routing, backend progress storage keyed by SessionId, and Effect-wrapped commands for testability with program-test.

**Tech Stack:** Elm, Lamdera, lamdera-program-test

---

## Task 1: Add Core Types

**Files:**
- Modify: `src/Types.elm`

**Step 1: Add Route, PuzzleId, StashId, and UserProgress types**

Replace the contents of `src/Types.elm` with:

```elm
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

import Dict exposing (Dict)
import Effect.Browser
import Effect.Browser.Navigation
import Effect.Lamdera


type Route
    = IntroRoute
    | HubRoute
    | PaintingsRoute
    | LedgerRoute
    | StashRoute
    | StashFoundRoute StashId
    | TileRoute
    | NotFoundRoute


type PuzzleId
    = Puzzle1
    | Puzzle2
    | Puzzle3
    | Puzzle4


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
    , puzzle4Complete : Bool
    }


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
    { userProgress : Dict Effect.Lamdera.SessionId UserProgress
    }


type FrontendMsg
    = UrlClicked Effect.Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | PuzzleInputChanged String
    | SubmitAnswer PuzzleId
    | ClickedBegin


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
```

**Step 2: Add missing import to Types.elm**

Add `import Url` to the imports in Types.elm.

**Step 3: Run the build to verify types compile**

Run: `cd /Users/elliotfiske/projects/commons-puzzlehunt && lamdera make src/Frontend.elm`
Expected: Compilation errors in Frontend.elm and Backend.elm (expected - they reference old types)

**Step 4: Commit types**

```bash
git add src/Types.elm
git commit -m "feat: add core types for puzzle hunt"
```

---

## Task 2: Add Route Parsing

**Files:**
- Create: `src/Route.elm`

**Step 1: Create Route module with URL parsing**

Create `src/Route.elm`:

```elm
module Route exposing (fromUrl, toPath)

import Types exposing (Route(..), StashId(..))
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


fromUrl : Url -> Route
fromUrl url =
    parse routeParser url
        |> Maybe.withDefault NotFoundRoute


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map IntroRoute top
        , map HubRoute (s "hub")
        , map PaintingsRoute (s "paintings")
        , map LedgerRoute (s "ledger")
        , map StashRoute (s "stash")
        , map parseStashFound (s "stash" </> string)
        , map TileRoute (s "tile")
        ]


parseStashFound : String -> Route
parseStashFound stashName =
    case stashName of
        "moonshine" ->
            StashFoundRoute Moonshine

        "whiskey" ->
            StashFoundRoute Whiskey

        "gin" ->
            StashFoundRoute Gin

        "bourbon" ->
            StashFoundRoute Bourbon

        "rum" ->
            StashFoundRoute Rum

        _ ->
            NotFoundRoute


toPath : Route -> String
toPath route =
    case route of
        IntroRoute ->
            "/"

        HubRoute ->
            "/hub"

        PaintingsRoute ->
            "/paintings"

        LedgerRoute ->
            "/ledger"

        StashRoute ->
            "/stash"

        StashFoundRoute stashId ->
            "/stash/" ++ stashIdToString stashId

        TileRoute ->
            "/tile"

        NotFoundRoute ->
            "/not-found"


stashIdToString : StashId -> String
stashIdToString stashId =
    case stashId of
        Moonshine ->
            "moonshine"

        Whiskey ->
            "whiskey"

        Gin ->
            "gin"

        Bourbon ->
            "bourbon"

        Rum ->
            "rum"
```

**Step 2: Run the build to verify Route module compiles**

Run: `cd /Users/elliotfiske/projects/commons-puzzlehunt && lamdera make src/Route.elm`
Expected: Successful compilation

**Step 3: Commit Route module**

```bash
git add src/Route.elm
git commit -m "feat: add URL routing with parser"
```

---

## Task 3: Update Backend for Progress Tracking

**Files:**
- Modify: `src/Backend.elm`

**Step 1: Update Backend with progress tracking**

Replace `src/Backend.elm` with:

```elm
module Backend exposing (BackendApp, Model, UnwrappedBackendApp, app, app_)

import Dict exposing (Dict)
import Effect.Command as Command exposing (BackendOnly, Command)
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Subscription as Subscription exposing (Subscription)
import Lamdera as L
import Types exposing (BackendModel, BackendMsg(..), PuzzleId(..), StashId(..), ToBackend(..), ToFrontend(..), UserProgress)


type alias Model =
    BackendModel


type alias BackendApp =
    { init : ( Model, Command BackendOnly ToFrontend BackendMsg )
    , update : BackendMsg -> Model -> ( Model, Command BackendOnly ToFrontend BackendMsg )
    , updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Command BackendOnly ToFrontend BackendMsg )
    , subscriptions : Model -> Subscription BackendOnly BackendMsg
    }


type alias UnwrappedBackendApp =
    { init : ( Model, Cmd BackendMsg )
    , update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
    , updateFromFrontend : String -> String -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
    , subscriptions : Model -> Sub BackendMsg
    }


app : UnwrappedBackendApp
app =
    Effect.Lamdera.backend
        L.broadcast
        L.sendToFrontend
        app_


app_ : BackendApp
app_ =
    { init = init
    , update = update
    , updateFromFrontend = updateFromFrontend
    , subscriptions = subscriptions
    }


subscriptions : Model -> Subscription BackendOnly BackendMsg
subscriptions _ =
    Subscription.batch
        [ Effect.Lamdera.onConnect ClientConnected
        , Effect.Lamdera.onDisconnect ClientDisconnected
        ]


init : ( Model, Command restriction toMsg BackendMsg )
init =
    ( { userProgress = Dict.empty }
    , Command.none
    )


emptyProgress : UserProgress
emptyProgress =
    { hasSeenIntro = False
    , puzzle1Complete = False
    , puzzle2Complete = False
    , puzzle3Stashes =
        { moonshine = False
        , whiskey = False
        , gin = False
        , bourbon = False
        , rum = False
        }
    , puzzle3Complete = False
    , puzzle4Complete = False
    }


getProgress : SessionId -> Model -> UserProgress
getProgress sessionId model =
    Dict.get sessionId model.userProgress
        |> Maybe.withDefault emptyProgress


update : BackendMsg -> Model -> ( Model, Command BackendOnly ToFrontend BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Command.none )

        ClientConnected sessionId clientId ->
            let
                progress =
                    getProgress sessionId model
            in
            ( model
            , Effect.Lamdera.sendToFrontend clientId (InitialState progress)
            )

        ClientDisconnected _ _ ->
            ( model, Command.none )


-- Puzzle answers (password, revealed number)
puzzleAnswers : PuzzleId -> ( String, String )
puzzleAnswers puzzleId =
    case puzzleId of
        Puzzle1 ->
            ( "SPEAKEASY", "7" )

        Puzzle2 ->
            ( "GULLIBLE", "3" )

        Puzzle3 ->
            ( "MOONSHINE", "1" )

        Puzzle4 ->
            ( "SECRET", "9" )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Command BackendOnly ToFrontend BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        MarkIntroSeen ->
            let
                progress =
                    getProgress sessionId model

                newProgress =
                    { progress | hasSeenIntro = True }

                newModel =
                    { model | userProgress = Dict.insert sessionId newProgress model.userProgress }
            in
            ( newModel
            , Effect.Lamdera.sendToFrontend clientId (InitialState newProgress)
            )

        SubmitPuzzleAnswer puzzleId answer ->
            let
                ( correctPassword, revealedNumber ) =
                    puzzleAnswers puzzleId

                isCorrect =
                    String.toUpper (String.trim answer) == correctPassword

                progress =
                    getProgress sessionId model

                newProgress =
                    if isCorrect then
                        case puzzleId of
                            Puzzle1 ->
                                { progress | puzzle1Complete = True }

                            Puzzle2 ->
                                { progress | puzzle2Complete = True }

                            Puzzle3 ->
                                { progress | puzzle3Complete = True }

                            Puzzle4 ->
                                { progress | puzzle4Complete = True }

                    else
                        progress

                newModel =
                    if isCorrect then
                        { model | userProgress = Dict.insert sessionId newProgress model.userProgress }

                    else
                        model

                response =
                    if isCorrect then
                        PuzzleAnswerResult puzzleId (Just revealedNumber)

                    else
                        PuzzleAnswerResult puzzleId Nothing
            in
            ( newModel
            , Effect.Lamdera.sendToFrontend clientId response
            )

        MarkStashFound stashId ->
            let
                progress =
                    getProgress sessionId model

                stashes =
                    progress.puzzle3Stashes

                newStashes =
                    case stashId of
                        Moonshine ->
                            { stashes | moonshine = True }

                        Whiskey ->
                            { stashes | whiskey = True }

                        Gin ->
                            { stashes | gin = True }

                        Bourbon ->
                            { stashes | bourbon = True }

                        Rum ->
                            { stashes | rum = True }

                newProgress =
                    { progress | puzzle3Stashes = newStashes }

                newModel =
                    { model | userProgress = Dict.insert sessionId newProgress model.userProgress }
            in
            ( newModel
            , Effect.Lamdera.sendToFrontend clientId (StashMarked stashId)
            )
```

**Step 2: Run the build to check Backend compiles**

Run: `cd /Users/elliotfiske/projects/commons-puzzlehunt && lamdera make src/Backend.elm`
Expected: Successful compilation

**Step 3: Commit Backend**

```bash
git add src/Backend.elm
git commit -m "feat: add backend progress tracking and answer validation"
```

---

## Task 4: Create Page View Modules

**Files:**
- Create: `src/Pages/Intro.elm`
- Create: `src/Pages/Hub.elm`
- Create: `src/Pages/Puzzle.elm`
- Create: `src/Pages/Stash.elm`

**Step 1: Create Pages directory**

Run: `mkdir -p /Users/elliotfiske/projects/commons-puzzlehunt/src/Pages`

**Step 2: Create Intro page**

Create `src/Pages/Intro.elm`:

```elm
module Pages.Intro exposing (view)

import Html exposing (Html, button, div, h1, p, text)
import Html.Events exposing (onClick)
import Types exposing (FrontendMsg(..))


view : Html FrontendMsg
view =
    div []
        [ h1 [] [ text "The Secret of the Commons" ]
        , p [] [ text "In the roaring 1920s, this very building housed one of San Francisco's most exclusive speakeasies..." ]
        , p [] [ text "Hidden passages, secret codes, and bootlegged spirits were the order of the day." ]
        , p [] [ text "Now, decades later, the secrets of the past are waiting to be uncovered." ]
        , p [] [ text "Can you crack the codes and unlock the mysteries of the Commons?" ]
        , button [ onClick ClickedBegin ] [ text "Begin" ]
        ]
```

**Step 3: Create Hub page**

Create `src/Pages/Hub.elm`:

```elm
module Pages.Hub exposing (view)

import Html exposing (Html, a, div, h1, h2, p, text)
import Html.Attributes exposing (href)
import Types exposing (FrontendMsg, UserProgress)


view : UserProgress -> Html FrontendMsg
view progress =
    div []
        [ h1 [] [ text "Puzzle Hub" ]
        , p [] [ text "Find all four numbers to unlock the safe." ]
        , div []
            [ puzzleCard "Paintings" "/paintings" progress.puzzle1Complete "7"
            , puzzleCard "Bootlegger's Ledger" "/ledger" progress.puzzle2Complete "3"
            , puzzleCard "Smuggler's Stash" "/stash" progress.puzzle3Complete "1"
            , puzzleCard "The Hidden Tile" "/tile" progress.puzzle4Complete "9"
            ]
        ]


puzzleCard : String -> String -> Bool -> String -> Html FrontendMsg
puzzleCard title path isComplete revealedNumber =
    div []
        [ h2 []
            [ a [ href path ] [ text title ]
            ]
        , if isComplete then
            p [] [ text ("Solved! The number is: " ++ revealedNumber) ]

          else
            p [] [ text "Not yet solved" ]
        ]
```

**Step 4: Create Puzzle page (shared for all 4 puzzles)**

Create `src/Pages/Puzzle.elm`:

```elm
module Pages.Puzzle exposing (view)

import Html exposing (Html, a, button, div, h1, input, p, text)
import Html.Attributes exposing (href, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Types exposing (AnswerResult(..), FrontendMsg(..), PuzzleId(..))


type alias PuzzleConfig =
    { title : String
    , description : String
    , puzzleId : PuzzleId
    }


view : PuzzleConfig -> String -> AnswerResult -> Bool -> Html FrontendMsg
view config inputValue answerResult isComplete =
    div []
        [ h1 [] [ text config.title ]
        , p [] [ text config.description ]
        , if isComplete then
            case answerResult of
                Correct _ number ->
                    div []
                        [ p [] [ text ("Correct! The number is: " ++ number) ]
                        , a [ href "/hub" ] [ text "Back to Hub" ]
                        ]

                _ ->
                    div []
                        [ p [] [ text "Already solved!" ]
                        , a [ href "/hub" ] [ text "Back to Hub" ]
                        ]

          else
            div []
                [ input
                    [ type_ "text"
                    , placeholder "Enter password"
                    , value inputValue
                    , onInput PuzzleInputChanged
                    ]
                    []
                , button [ onClick (SubmitAnswer config.puzzleId) ] [ text "Submit" ]
                , viewAnswerFeedback answerResult config.puzzleId
                , p [] [ a [ href "/hub" ] [ text "Back to Hub" ] ]
                ]
        ]


viewAnswerFeedback : AnswerResult -> PuzzleId -> Html FrontendMsg
viewAnswerFeedback result currentPuzzle =
    case result of
        NoAnswerYet ->
            text ""

        Incorrect puzzleId ->
            if puzzleId == currentPuzzle then
                p [] [ text "Incorrect. Try again!" ]

            else
                text ""

        Correct puzzleId number ->
            if puzzleId == currentPuzzle then
                p [] [ text ("Correct! The number is: " ++ number) ]

            else
                text ""
```

**Step 5: Create Stash page**

Create `src/Pages/Stash.elm`:

```elm
module Pages.Stash exposing (viewFound, viewPuzzle)

import Html exposing (Html, a, button, div, h1, h2, input, li, p, text, ul)
import Html.Attributes exposing (href, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Types exposing (AnswerResult(..), FrontendMsg(..), PuzzleId(..), StashId(..), StashProgress)


viewPuzzle : StashProgress -> String -> AnswerResult -> Bool -> Html FrontendMsg
viewPuzzle stashes inputValue answerResult isComplete =
    div []
        [ h1 [] [ text "Smuggler's Stash" ]
        , p [] [ text "Find all the hidden stashes around the Commons!" ]
        , h2 [] [ text "Stashes Found:" ]
        , ul []
            [ stashItem "Moonshine" stashes.moonshine
            , stashItem "Whiskey" stashes.whiskey
            , stashItem "Gin" stashes.gin
            , stashItem "Bourbon" stashes.bourbon
            , stashItem "Rum" stashes.rum
            ]
        , if isComplete then
            case answerResult of
                Correct _ number ->
                    div []
                        [ p [] [ text ("Correct! The number is: " ++ number) ]
                        , a [ href "/hub" ] [ text "Back to Hub" ]
                        ]

                _ ->
                    div []
                        [ p [] [ text "Already solved!" ]
                        , a [ href "/hub" ] [ text "Back to Hub" ]
                        ]

          else
            div []
                [ p [] [ text "Enter the final password:" ]
                , input
                    [ type_ "text"
                    , placeholder "Enter password"
                    , value inputValue
                    , onInput PuzzleInputChanged
                    ]
                    []
                , button [ onClick (SubmitAnswer Puzzle3) ] [ text "Submit" ]
                , viewAnswerFeedback answerResult
                , p [] [ a [ href "/hub" ] [ text "Back to Hub" ] ]
                ]
        ]


stashItem : String -> Bool -> Html FrontendMsg
stashItem name found =
    li []
        [ text
            (name
                ++ ": "
                ++ (if found then
                        "Found!"

                    else
                        "Not found"
                   )
            )
        ]


viewAnswerFeedback : AnswerResult -> Html FrontendMsg
viewAnswerFeedback result =
    case result of
        NoAnswerYet ->
            text ""

        Incorrect Puzzle3 ->
            p [] [ text "Incorrect. Try again!" ]

        Incorrect _ ->
            text ""

        Correct Puzzle3 number ->
            p [] [ text ("Correct! The number is: " ++ number) ]

        Correct _ _ ->
            text ""


viewFound : StashId -> Bool -> Html FrontendMsg
viewFound stashId hasSeenIntro =
    let
        stashName =
            case stashId of
                Moonshine ->
                    "Moonshine"

                Whiskey ->
                    "Whiskey"

                Gin ->
                    "Gin"

                Bourbon ->
                    "Bourbon"

                Rum ->
                    "Rum"
    in
    div []
        [ h1 [] [ text "You found a stash!" ]
        , p [] [ text ("You discovered the " ++ stashName ++ " stash!") ]
        , if hasSeenIntro then
            a [ href "/stash" ] [ text "Back to Smuggler's Stash" ]

          else
            div []
                [ p [] [ text "You've stumbled upon a secret! Start the puzzle hunt to track your progress." ]
                , a [ href "/" ] [ text "Begin the Hunt" ]
                ]
        ]
```

**Step 6: Run the build to check Pages compile**

Run: `cd /Users/elliotfiske/projects/commons-puzzlehunt && lamdera make src/Pages/Intro.elm src/Pages/Hub.elm src/Pages/Puzzle.elm src/Pages/Stash.elm`
Expected: Successful compilation

**Step 7: Commit Page modules**

```bash
git add src/Pages/
git commit -m "feat: add page view modules for intro, hub, puzzle, and stash"
```

---

## Task 5: Update Frontend with Routing and Views

**Files:**
- Modify: `src/Frontend.elm`

**Step 1: Update Frontend.elm with full routing and views**

Replace `src/Frontend.elm` with:

```elm
module Frontend exposing (FrontendApp, Model, UnwrappedFrontendApp, app, app_)

import Browser
import Browser.Navigation
import Effect.Browser exposing (UrlRequest(..))
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Effect.Subscription as Subscription exposing (Subscription)
import Html exposing (Html, div, h1, p, text)
import Lamdera as L
import Pages.Hub
import Pages.Intro
import Pages.Puzzle
import Pages.Stash
import Route
import Types exposing (AnswerResult(..), FrontendModel, FrontendMsg(..), PuzzleId(..), Route(..), StashId, ToBackend(..), ToFrontend(..), UserProgress)
import Url


type alias Model =
    FrontendModel


app_ : FrontendApp
app_ =
    { init = init
    , onUrlRequest = UrlClicked
    , onUrlChange = UrlChanged
    , update = update
    , updateFromBackend = updateFromBackend
    , subscriptions = \_ -> Subscription.none
    , view = view
    }


init : Url.Url -> Effect.Browser.Navigation.Key -> ( Model, Command FrontendOnly ToBackend FrontendMsg )
init url key =
    ( { key = key
      , route = Route.fromUrl url
      , userProgress = Nothing
      , puzzleInput = ""
      , lastAnswerResult = NoAnswerYet
      }
    , Command.none
    )


update : FrontendMsg -> Model -> ( Model, Command FrontendOnly ToBackend FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Effect.Browser.Navigation.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Effect.Browser.Navigation.load url
                    )

        UrlChanged url ->
            let
                newRoute =
                    Route.fromUrl url

                -- Clear input and answer result when changing to a puzzle page
                ( newInput, newResult ) =
                    case newRoute of
                        PaintingsRoute ->
                            ( "", NoAnswerYet )

                        LedgerRoute ->
                            ( "", NoAnswerYet )

                        StashRoute ->
                            ( "", NoAnswerYet )

                        TileRoute ->
                            ( "", NoAnswerYet )

                        _ ->
                            ( model.puzzleInput, model.lastAnswerResult )

                -- If landing on a StashFoundRoute, mark the stash as found
                cmd =
                    case newRoute of
                        StashFoundRoute stashId ->
                            case model.userProgress of
                                Just progress ->
                                    if progress.hasSeenIntro then
                                        Effect.Lamdera.sendToBackend (MarkStashFound stashId)

                                    else
                                        Command.none

                                Nothing ->
                                    Command.none

                        _ ->
                            Command.none
            in
            ( { model | route = newRoute, puzzleInput = newInput, lastAnswerResult = newResult }
            , cmd
            )

        NoOpFrontendMsg ->
            ( model, Command.none )

        PuzzleInputChanged value ->
            ( { model | puzzleInput = value }, Command.none )

        SubmitAnswer puzzleId ->
            ( model
            , Effect.Lamdera.sendToBackend (SubmitPuzzleAnswer puzzleId model.puzzleInput)
            )

        ClickedBegin ->
            ( model
            , Command.batch
                [ Effect.Lamdera.sendToBackend MarkIntroSeen
                , Effect.Browser.Navigation.pushUrl model.key "/hub"
                ]
            )


updateFromBackend : ToFrontend -> Model -> ( Model, Command FrontendOnly ToBackend FrontendMsg )
updateFromBackend msg model =
    case msg of
        InitialState progress ->
            ( { model | userProgress = Just progress }, Command.none )

        PuzzleAnswerResult puzzleId maybeNumber ->
            let
                newResult =
                    case maybeNumber of
                        Just number ->
                            Correct puzzleId number

                        Nothing ->
                            Incorrect puzzleId

                newProgress =
                    case maybeNumber of
                        Just _ ->
                            Maybe.map (markPuzzleComplete puzzleId) model.userProgress

                        Nothing ->
                            model.userProgress
            in
            ( { model | lastAnswerResult = newResult, userProgress = newProgress }, Command.none )

        StashMarked stashId ->
            let
                newProgress =
                    Maybe.map (markStashFound stashId) model.userProgress
            in
            ( { model | userProgress = newProgress }, Command.none )


markPuzzleComplete : PuzzleId -> UserProgress -> UserProgress
markPuzzleComplete puzzleId progress =
    case puzzleId of
        Puzzle1 ->
            { progress | puzzle1Complete = True }

        Puzzle2 ->
            { progress | puzzle2Complete = True }

        Puzzle3 ->
            { progress | puzzle3Complete = True }

        Puzzle4 ->
            { progress | puzzle4Complete = True }


markStashFound : StashId -> UserProgress -> UserProgress
markStashFound stashId progress =
    let
        stashes =
            progress.puzzle3Stashes

        newStashes =
            case stashId of
                Types.Moonshine ->
                    { stashes | moonshine = True }

                Types.Whiskey ->
                    { stashes | whiskey = True }

                Types.Gin ->
                    { stashes | gin = True }

                Types.Bourbon ->
                    { stashes | bourbon = True }

                Types.Rum ->
                    { stashes | rum = True }
    in
    { progress | puzzle3Stashes = newStashes }


view : Model -> Effect.Browser.Document FrontendMsg
view model =
    { title = "The Secret of the Commons"
    , body = [ viewBody model ]
    }


viewBody : Model -> Html FrontendMsg
viewBody model =
    case model.userProgress of
        Nothing ->
            div [] [ text "Loading..." ]

        Just progress ->
            viewWithProgress model progress


viewWithProgress : Model -> UserProgress -> Html FrontendMsg
viewWithProgress model progress =
    case model.route of
        IntroRoute ->
            if progress.hasSeenIntro then
                -- Redirect to hub (handled by showing hub content)
                Pages.Hub.view progress

            else
                Pages.Intro.view

        HubRoute ->
            if progress.hasSeenIntro then
                Pages.Hub.view progress

            else
                Pages.Intro.view

        PaintingsRoute ->
            Pages.Puzzle.view
                { title = "The Paintings"
                , description = "Several paintings hang around the Commons. Each has a Post-it note with letters. Find them all and spell out the clue to discover the password."
                , puzzleId = Puzzle1
                }
                model.puzzleInput
                model.lastAnswerResult
                progress.puzzle1Complete

        LedgerRoute ->
            Pages.Puzzle.view
                { title = "Bootlegger's Ledger"
                , description = "The bootlegger kept meticulous records. Use the book cipher (page, line, word) with books from the Commons library to decode the message."
                , puzzleId = Puzzle2
                }
                model.puzzleInput
                model.lastAnswerResult
                progress.puzzle2Complete

        StashRoute ->
            Pages.Stash.viewPuzzle
                progress.puzzle3Stashes
                model.puzzleInput
                model.lastAnswerResult
                progress.puzzle3Complete

        StashFoundRoute stashId ->
            Pages.Stash.viewFound stashId progress.hasSeenIntro

        TileRoute ->
            Pages.Puzzle.view
                { title = "The Hidden Tile"
                , description = "Somewhere in the Commons, a secret awaits discovery. Find the hidden tile to reveal the final password."
                , puzzleId = Puzzle4
                }
                model.puzzleInput
                model.lastAnswerResult
                progress.puzzle4Complete

        NotFoundRoute ->
            div []
                [ h1 [] [ text "Page Not Found" ]
                , p [] [ text "This page doesn't exist." ]
                ]


type alias FrontendApp =
    { init : Url.Url -> Effect.Browser.Navigation.Key -> ( Model, Command FrontendOnly ToBackend FrontendMsg )
    , onUrlRequest : Effect.Browser.UrlRequest -> FrontendMsg
    , onUrlChange : Url.Url -> FrontendMsg
    , update : FrontendMsg -> Model -> ( Model, Command FrontendOnly ToBackend FrontendMsg )
    , updateFromBackend : ToFrontend -> Model -> ( Model, Command FrontendOnly ToBackend FrontendMsg )
    , subscriptions : Model -> Subscription FrontendOnly FrontendMsg
    , view : Model -> Effect.Browser.Document FrontendMsg
    }


type alias UnwrappedFrontendApp =
    { init : Url.Url -> Browser.Navigation.Key -> ( Model, Cmd FrontendMsg )
    , view : Model -> Browser.Document FrontendMsg
    , update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
    , updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
    , subscriptions : Model -> Sub FrontendMsg
    , onUrlRequest : Browser.UrlRequest -> FrontendMsg
    , onUrlChange : Url.Url -> FrontendMsg
    }


app : UnwrappedFrontendApp
app =
    Effect.Lamdera.frontend
        L.sendToBackend
        app_
```

**Step 2: Run the build to verify everything compiles**

Run: `cd /Users/elliotfiske/projects/commons-puzzlehunt && lamdera make src/Frontend.elm`
Expected: Successful compilation

**Step 3: Commit Frontend**

```bash
git add src/Frontend.elm
git commit -m "feat: add frontend routing and page views"
```

---

## Task 6: Update Tests

**Files:**
- Modify: `tests/SmokeTests.elm`

**Step 1: Update SmokeTests with puzzle hunt scenarios**

Replace `tests/SmokeTests.elm` with:

```elm
module SmokeTests exposing (appTests, main)

import Backend
import Effect.Lamdera
import Effect.Test exposing (HttpResponse(..))
import Effect.Time
import Frontend
import Test exposing (describe)
import Test.Html.Query
import Test.Html.Selector exposing (exactText, tag, text)
import Types exposing (BackendModel, BackendMsg, FrontendModel, FrontendMsg, ToBackend, ToFrontend)
import Url exposing (Url)


main : Program () (Effect.Test.Model ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel) (Effect.Test.Msg ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel)
main =
    Effect.Test.viewer tests


tests : List (Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel)
tests =
    [ testFirstVisitShowsIntro
    , testClickingBeginGoesToHub
    , testReturningUserSkipsIntro
    , testWrongPasswordShowsIncorrect
    , testCorrectPasswordShowsNumber
    , testStashFoundPageForNewUser
    ]


testFirstVisitShowsIntro : Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
testFirstVisitShowsIntro =
    Effect.Test.start
        "First visit shows intro"
        (Effect.Time.millisToPosix 0)
        config
        [ Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString "session1")
            "/"
            { width = 800, height = 600 }
            (\client ->
                [ client.checkView 100 (Test.Html.Query.has [ exactText "The Secret of the Commons" ])
                , client.checkView 100 (Test.Html.Query.has [ exactText "Begin" ])
                ]
            )
        ]


testClickingBeginGoesToHub : Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
testClickingBeginGoesToHub =
    Effect.Test.start
        "Clicking Begin goes to hub"
        (Effect.Time.millisToPosix 0)
        config
        [ Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString "session2")
            "/"
            { width = 800, height = 600 }
            (\client ->
                [ client.clickButton 100 "Begin"
                , client.checkView 100 (Test.Html.Query.has [ exactText "Puzzle Hub" ])
                ]
            )
        ]


testReturningUserSkipsIntro : Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
testReturningUserSkipsIntro =
    Effect.Test.start
        "Returning user skips intro"
        (Effect.Time.millisToPosix 0)
        config
        [ Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString "session3")
            "/"
            { width = 800, height = 600 }
            (\client ->
                [ client.clickButton 100 "Begin"
                , client.checkView 100 (Test.Html.Query.has [ exactText "Puzzle Hub" ])
                ]
            )
        , -- Same session reconnects
          Effect.Test.connectFrontend
            2000
            (Effect.Lamdera.sessionIdFromString "session3")
            "/"
            { width = 800, height = 600 }
            (\client ->
                [ -- Should skip intro and show hub
                  client.checkView 100 (Test.Html.Query.has [ exactText "Puzzle Hub" ])
                ]
            )
        ]


testWrongPasswordShowsIncorrect : Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
testWrongPasswordShowsIncorrect =
    Effect.Test.start
        "Wrong password shows incorrect"
        (Effect.Time.millisToPosix 0)
        config
        [ Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString "session4")
            "/"
            { width = 800, height = 600 }
            (\client ->
                [ client.clickButton 100 "Begin"
                , client.clickLink 100 "Paintings"
                , client.inputText 100 "Enter password" "WRONGPASSWORD"
                , client.clickButton 100 "Submit"
                , client.checkView 100 (Test.Html.Query.has [ text "Incorrect" ])
                ]
            )
        ]


testCorrectPasswordShowsNumber : Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
testCorrectPasswordShowsNumber =
    Effect.Test.start
        "Correct password shows number"
        (Effect.Time.millisToPosix 0)
        config
        [ Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString "session5")
            "/"
            { width = 800, height = 600 }
            (\client ->
                [ client.clickButton 100 "Begin"
                , client.clickLink 100 "Paintings"
                , client.inputText 100 "Enter password" "SPEAKEASY"
                , client.clickButton 100 "Submit"
                , client.checkView 100 (Test.Html.Query.has [ text "The number is: 7" ])
                ]
            )
        ]


testStashFoundPageForNewUser : Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
testStashFoundPageForNewUser =
    Effect.Test.start
        "Stash found page for new user shows begin link"
        (Effect.Time.millisToPosix 0)
        config
        [ Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString "session6")
            "/stash/moonshine"
            { width = 800, height = 600 }
            (\client ->
                [ client.checkView 100 (Test.Html.Query.has [ exactText "You found a stash!" ])
                , client.checkView 100 (Test.Html.Query.has [ exactText "Begin the Hunt" ])
                ]
            )
        ]


safeUrl : Url
safeUrl =
    { protocol = Url.Https
    , host = "puzzle.lamdera.app"
    , port_ = Nothing
    , path = "/"
    , query = Nothing
    , fragment = Nothing
    }


config : Effect.Test.Config ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
config =
    { frontendApp = Frontend.app_
    , backendApp = Backend.app_
    , handleHttpRequest = always NetworkErrorResponse
    , handlePortToJs = always Nothing
    , handleFileUpload = always Effect.Test.UnhandledFileUpload
    , handleMultipleFilesUpload = always Effect.Test.UnhandledMultiFileUpload
    , domain = safeUrl
    }


appTests : Test.Test
appTests =
    describe "Puzzle Hunt tests" (List.map Effect.Test.toTest tests)
```

**Step 2: Run tests to verify they compile**

Run: `cd /Users/elliotfiske/projects/commons-puzzlehunt && npx elm-test-rs tests/SmokeTests.elm`
Expected: Tests compile and run (some may fail until implementation is complete)

**Step 3: Commit tests**

```bash
git add tests/SmokeTests.elm
git commit -m "feat: add E2E tests for puzzle hunt flows"
```

---

## Task 7: Run Full Build and Tests

**Step 1: Run Lamdera build**

Run: `cd /Users/elliotfiske/projects/commons-puzzlehunt && lamdera make src/Frontend.elm src/Backend.elm`
Expected: Successful compilation

**Step 2: Run all tests**

Run: `cd /Users/elliotfiske/projects/commons-puzzlehunt && npx elm-test-rs tests/SmokeTests.elm`
Expected: All tests pass

**Step 3: Start Lamdera dev server and manually verify**

Run: `cd /Users/elliotfiske/projects/commons-puzzlehunt && lamdera live`
Expected: Server starts, visit http://localhost:8000 to see intro page

---

## Summary

After completing all tasks, you will have:
- Core types for routing, puzzles, stashes, and user progress
- URL parsing for all routes
- Backend that tracks progress per session and validates answers
- Frontend with all page views (intro, hub, 4 puzzles, stash found)
- E2E tests covering key user flows
