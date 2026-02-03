module Backend exposing (BackendApp, Model, UnwrappedBackendApp, app, app_)

import Effect.Command as Command exposing (BackendOnly, Command)
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Subscription as Subscription exposing (Subscription)
import Lamdera as L
import PuzzleData
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
    ( { userProgress = SeqDict.empty
      , sessionClients = SeqDict.empty
      }
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

                currentClients =
                    SeqDict.get sessionId model.sessionClients
                        |> Maybe.withDefault []

                newClients =
                    clientId :: currentClients

                newModel =
                    { model | sessionClients = SeqDict.insert sessionId newClients model.sessionClients }
            in
            ( newModel
            , Effect.Lamdera.sendToFrontend clientId (InitialState progress)
            )

        ClientDisconnected sessionId clientId ->
            let
                currentClients =
                    SeqDict.get sessionId model.sessionClients
                        |> Maybe.withDefault []

                newClients =
                    List.filter (\c -> c /= clientId) currentClients

                newModel =
                    { model | sessionClients = SeqDict.insert sessionId newClients model.sessionClients }
            in
            ( newModel, Command.none )



updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Command BackendOnly ToFrontend BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        RequestInitialState ->
            let
                progress =
                    getProgress sessionId model
            in
            ( model
            , Effect.Lamdera.sendToFrontend clientId (InitialState progress)
            )

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
                isCorrect =
                    String.toUpper (String.trim answer) == PuzzleData.password puzzleId

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

                                else
                                    progress
                        in
                        { model | userProgress = SeqDict.insert sessionId newProgress model.userProgress }

                    else
                        model

                response =
                    if isCorrect then
                        PuzzleAnswerResult puzzleId (Just (PuzzleData.revealedNumber puzzleId))

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

                allFound =
                    newStashes.moonshine && newStashes.whiskey && newStashes.gin && newStashes.bourbon && newStashes.rum

                newProgress =
                    { progress | puzzle3Stashes = newStashes, puzzle3Complete = allFound }

                newModel =
                    { model | userProgress = SeqDict.insert sessionId newProgress model.userProgress }

                -- Notify all clients for this session
                clients =
                    SeqDict.get sessionId model.sessionClients
                        |> Maybe.withDefault []

                commands =
                    clients
                        |> List.map (\cid -> Effect.Lamdera.sendToFrontend cid (StashMarked stashId))
                        |> Command.batch
            in
            ( newModel, commands )
