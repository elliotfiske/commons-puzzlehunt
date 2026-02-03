module SmokeTests exposing (appTests, main)

import Backend
import Effect.Browser.Dom as Dom
import Effect.Lamdera
import Effect.Test exposing (HttpResponse(..))
import Effect.Time
import Frontend
import Test exposing (describe)
import Test.Html.Query
import Test.Html.Selector exposing (exactText, text)
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
    , testCorrectPasswordShowsNumber
    , testStashFoundPageForNewUser
    , testStashBroadcastToSameSession
    ]
        ++ paintingsInputTests


type ExpectedResult
    = ExpectHint
    | ExpectIncorrect


paintingsInputTests : List (Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel)
paintingsInputTests =
    List.indexedMap paintingsInputTest
        [ ( "ABOVE THE PULLUP BAR", ExpectHint )
        , ( "above the pullup bar", ExpectHint )
        , ( "Above the pull-up bar", ExpectHint )
        , ( "ABOVETHEPULLUPBAR", ExpectHint )
        , ( "WRONG ANSWER", ExpectIncorrect )
        , ( "above the bar", ExpectIncorrect )
        ]


paintingsInputTest : Int -> ( String, ExpectedResult ) -> Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
paintingsInputTest index ( input, expected ) =
    let
        sessionId =
            "paintings-input-" ++ String.fromInt index

        ( testName, viewChecks ) =
            case expected of
                ExpectHint ->
                    ( "Paintings: \"" ++ input ++ "\" shows hint"
                    , \actions ->
                        [ actions.checkView 100 (Test.Html.Query.has [ text "You're on the right track" ])
                        , actions.checkView 100 (Test.Html.Query.hasNot [ text "Incorrect" ])
                        ]
                    )

                ExpectIncorrect ->
                    ( "Paintings: \"" ++ input ++ "\" shows incorrect"
                    , \actions ->
                        [ actions.checkView 100 (Test.Html.Query.has [ text "Incorrect" ])
                        , actions.checkView 100 (Test.Html.Query.hasNot [ text "You're on the right track" ])
                        ]
                    )
    in
    Effect.Test.start
        testName
        (Effect.Time.millisToPosix 0)
        config
        [ Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString sessionId)
            "/"
            { width = 800, height = 600 }
            (\actions ->
                [ actions.click 100 (Dom.id "begin-btn")
                , actions.click 100 (Dom.id "paintings-link")
                , actions.input 100 (Dom.id "password-input") input
                , actions.click 100 (Dom.id "submit-btn")
                ]
                    ++ viewChecks actions
            )
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
            (\actions ->
                [ actions.click 100 (Dom.id "begin-btn")
                , actions.checkView 100 (Test.Html.Query.has [ exactText "Puzzle Hub" ])
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
            (\actions ->
                [ actions.click 100 (Dom.id "begin-btn")
                , actions.checkView 100 (Test.Html.Query.has [ exactText "Puzzle Hub" ])
                ]
            )
        , -- Same session reconnects
          Effect.Test.connectFrontend
            2000
            (Effect.Lamdera.sessionIdFromString "session3")
            "/"
            { width = 800, height = 600 }
            (\actions ->
                [ -- Should skip intro and show hub
                  actions.checkView 100 (Test.Html.Query.has [ exactText "Puzzle Hub" ])
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
            (\actions ->
                [ actions.click 100 (Dom.id "begin-btn")
                , actions.click 100 (Dom.id "paintings-link")
                , actions.input 100 (Dom.id "password-input") "RAISE YOUR SPIRITS"
                , actions.click 100 (Dom.id "submit-btn")
                , actions.checkView 100 (Test.Html.Query.has [ text "The number is: J" ])
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
            "/stash/jonathans-moonshine"
            { width = 800, height = 600 }
            (\client ->
                [ client.checkView 100 (Test.Html.Query.has [ exactText "You found a stash!" ])
                , client.checkView 100 (Test.Html.Query.has [ exactText "Begin the Hunt" ])
                ]
            )
        ]


testStashBroadcastToSameSession : Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
testStashBroadcastToSameSession =
    Effect.Test.start
        "Stash found broadcasts to all clients in same session but not other sessions"
        (Effect.Time.millisToPosix 0)
        config
        [ -- Client A (session7): Start the hunt and go to stash page
          Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString "session7")
            "/"
            { width = 800, height = 600 }
            (\clientA ->
                [ clientA.click 100 (Dom.id "begin-btn")
                , clientA.click 100 (Dom.id "stash-link")
                , -- Initially, Moonshine should not be found
                  clientA.checkView 100 (Test.Html.Query.hasNot [ exactText "Found!" ])
                , -- Connect Client B (same session) who scans a QR code
                  Effect.Test.connectFrontend
                    0
                    (Effect.Lamdera.sessionIdFromString "session7")
                    "/stash/jonathans-moonshine"
                    { width = 800, height = 600 }
                    (\clientB ->
                        [ -- Client B sees the "found" page
                          clientB.checkView 100 (Test.Html.Query.has [ exactText "You found a stash!" ])
                        , -- Wait for backend to process and broadcast
                          Effect.Test.andThen 500
                            (\_ ->
                                [ -- Client A should now see "Found!" due to broadcast
                                  clientA.checkView 0 (Test.Html.Query.has [ exactText "Found!" ])
                                ]
                            )
                        ]
                    )
                , -- Connect Client C (different session) who should NOT see the stash found
                  Effect.Test.connectFrontend
                    0
                    (Effect.Lamdera.sessionIdFromString "session8")
                    "/"
                    { width = 800, height = 600 }
                    (\clientC ->
                        [ clientC.click 100 (Dom.id "begin-btn")
                        , clientC.click 100 (Dom.id "stash-link")
                        , -- Client C should NOT see any "Found!" since they're a different session
                          clientC.checkView 100 (Test.Html.Query.hasNot [ exactText "Found!" ])
                        ]
                    )
                ]
            )
        ]


safeUrl : Url
safeUrl =
    { protocol = Url.Https
    , host = "speakeasy.lamdera.app"
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
