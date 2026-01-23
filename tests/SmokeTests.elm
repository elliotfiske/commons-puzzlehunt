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
            (\actions ->
                [ actions.click 100 (Dom.id "begin-btn")
                , actions.click 100 (Dom.id "paintings-link")
                , actions.input 100 (Dom.id "password-input") "WRONGPASSWORD"
                , actions.click 100 (Dom.id "submit-btn")
                , actions.checkView 100 (Test.Html.Query.has [ text "Incorrect" ])
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
                , actions.checkView 100 (Test.Html.Query.has [ text "The number is: 7" ])
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
