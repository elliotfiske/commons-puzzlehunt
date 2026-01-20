module Frontend exposing (FrontendApp, Model, UnwrappedFrontendApp, app, app_)

import Browser exposing (UrlRequest(..))
import Browser.Navigation
import Effect.Browser exposing (UrlRequest)
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

        NavigateTo path ->
            ( model
            , Effect.Browser.Navigation.pushUrl model.key path
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
                , description = "Several paintings hang around the Commons. Find them all and spell out the clue to discover the password."
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
