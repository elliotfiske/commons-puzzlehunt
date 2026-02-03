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
    , testFinaleAppearsWhenAllPuzzlesSolved
    , testFinaleHiddenWhenPuzzlesIncomplete
    , testDebugResetClearsProgress
    , testThanksPageShowsCorrectContent
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
                , actions.checkView 100 (Test.Html.Query.has [ text "One part of the combination is: J" ])
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


testFinaleAppearsWhenAllPuzzlesSolved : Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
testFinaleAppearsWhenAllPuzzlesSolved =
    Effect.Test.start
        "Finale appears when all puzzles solved"
        (Effect.Time.millisToPosix 0)
        config
        [ Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString "finale-test-session")
            "/"
            { width = 800, height = 600 }
            (\actions ->
                [ -- Complete intro
                  actions.click 100 (Dom.id "begin-btn")
                , -- Solve puzzle 1
                  actions.click 100 (Dom.id "paintings-link")
                , actions.input 100 (Dom.id "password-input") "RAISE YOUR SPIRITS"
                , actions.click 100 (Dom.id "submit-btn")
                , actions.click 100 (Dom.id "back-to-hub-link")
                , -- Solve puzzle 2
                  actions.click 100 (Dom.id "ledger-link")
                , actions.input 100 (Dom.id "password-input") "COOK THE BOOKS"
                , actions.click 100 (Dom.id "submit-btn")
                , actions.click 100 (Dom.id "back-to-hub-link")
                , -- Find all stashes for puzzle 3
                  Effect.Test.connectFrontend
                    0
                    (Effect.Lamdera.sessionIdFromString "finale-test-session")
                    "/stash/jonathans-moonshine"
                    { width = 800, height = 600 }
                    (\_ -> [])
                , Effect.Test.connectFrontend
                    0
                    (Effect.Lamdera.sessionIdFromString "finale-test-session")
                    "/stash/jonnys-whiskey"
                    { width = 800, height = 600 }
                    (\_ -> [])
                , Effect.Test.connectFrontend
                    0
                    (Effect.Lamdera.sessionIdFromString "finale-test-session")
                    "/stash/josukes-gin"
                    { width = 800, height = 600 }
                    (\_ -> [])
                , Effect.Test.connectFrontend
                    0
                    (Effect.Lamdera.sessionIdFromString "finale-test-session")
                    "/stash/jolenes-bourbon"
                    { width = 800, height = 600 }
                    (\_ -> [])
                , Effect.Test.connectFrontend
                    0
                    (Effect.Lamdera.sessionIdFromString "finale-test-session")
                    "/stash/jotaros-rum"
                    { width = 800, height = 600 }
                    (\_ -> [])
                , -- Wait for stash updates to propagate, then check finale on hub
                  Effect.Test.andThen 500
                    (\_ ->
                        [ -- Client is already on hub, just check for finale
                          actions.checkView 100 (Test.Html.Query.has [ exactText "The Code is Yours" ])
                        , actions.checkView 100 (Test.Html.Query.has [ text "lockbox awaits" ])
                        ]
                    )
                ]
            )
        ]


testFinaleHiddenWhenPuzzlesIncomplete : Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
testFinaleHiddenWhenPuzzlesIncomplete =
    Effect.Test.start
        "Finale hidden when puzzles incomplete"
        (Effect.Time.millisToPosix 0)
        config
        [ Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString "no-finale-session")
            "/"
            { width = 800, height = 600 }
            (\actions ->
                [ -- Complete intro and go to hub
                  actions.click 100 (Dom.id "begin-btn")
                , -- Finale should not be visible
                  actions.checkView 100 (Test.Html.Query.hasNot [ exactText "The Code is Yours" ])
                , -- Solve only puzzle 1
                  actions.click 100 (Dom.id "paintings-link")
                , actions.input 100 (Dom.id "password-input") "RAISE YOUR SPIRITS"
                , actions.click 100 (Dom.id "submit-btn")
                , actions.click 100 (Dom.id "back-to-hub-link")
                , -- Finale should still not be visible
                  actions.checkView 100 (Test.Html.Query.hasNot [ exactText "The Code is Yours" ])
                ]
            )
        ]


testDebugResetClearsProgress : Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
testDebugResetClearsProgress =
    Effect.Test.start
        "Debug reset clears all progress"
        (Effect.Time.millisToPosix 0)
        config
        [ Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString "debug-reset-session")
            "/"
            { width = 800, height = 600 }
            (\actions ->
                [ -- Complete intro to establish some state
                  actions.click 100 (Dom.id "begin-btn")
                , actions.checkView 100 (Test.Html.Query.has [ exactText "Puzzle Hub" ])
                , -- Navigate to debug reset page
                  Effect.Test.connectFrontend
                    0
                    (Effect.Lamdera.sessionIdFromString "debug-reset-session")
                    "/debug-reset"
                    { width = 800, height = 600 }
                    (\resetActions ->
                        [ -- Should see a reset button
                          resetActions.checkView 100 (Test.Html.Query.has [ exactText "Reset All Progress" ])
                        , -- Click the reset button
                          resetActions.click 100 (Dom.id "reset-btn")
                        , -- Should be redirected to intro (showing state was reset)
                          resetActions.checkView 100 (Test.Html.Query.has [ exactText "The Secret of the Commons" ])
                        , resetActions.checkView 100 (Test.Html.Query.has [ exactText "Begin" ])
                        ]
                    )
                ]
            )
        ]


testThanksPageShowsCorrectContent : Effect.Test.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel
testThanksPageShowsCorrectContent =
    Effect.Test.start
        "Thanks page shows correct content"
        (Effect.Time.millisToPosix 0)
        config
        [ Effect.Test.connectFrontend
            1000
            (Effect.Lamdera.sessionIdFromString "thanks-test-session")
            "/thanks"
            { width = 800, height = 600 }
            (\actions ->
                [ actions.checkView 100 (Test.Html.Query.has [ exactText "Thanks for Playing!" ])
                , actions.checkView 100 (Test.Html.Query.has [ text "We hope you enjoyed the puzzle hunt!" ])
                , actions.checkView 100 (Test.Html.Query.has [ exactText "Share Your Feedback" ])
                , actions.checkView 100 (Test.Html.Query.has [ exactText "Back to Puzzle Hub" ])
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
