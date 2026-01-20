module Backend exposing (BackendApp, Model, UnwrappedBackendApp, app, app_)

import Effect.Command as Command exposing (BackendOnly, Command)
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Subscription as Subscription exposing (Subscription)
import Lamdera as L
import SeqDict
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
    ( { userProgress = SeqDict.empty }
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
    SeqDict.get sessionId model.userProgress
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
            ( "RAISE YOUR SPIRITS", "5" )

        Puzzle4 ->
            ( "SECRET", "7" )


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
                    { model | userProgress = SeqDict.insert sessionId newProgress model.userProgress }
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

                newModel =
                    if isCorrect then
                        let
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
                        in
                        { model | userProgress = SeqDict.insert sessionId newProgress model.userProgress }

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
                    { model | userProgress = SeqDict.insert sessionId newProgress model.userProgress }
            in
            ( newModel
            , Effect.Lamdera.sendToFrontend clientId (StashMarked stashId)
            )
