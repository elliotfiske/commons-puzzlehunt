module Pages.Help exposing (view)

import Html exposing (Html, a, div, h1, p, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Types exposing (FrontendMsg(..))


view : Html FrontendMsg
view =
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ h1 [ class "heading-deco" ] [ text "Need Help?" ]
            , div [ class "divider-deco" ] []
            , p [ class "body-text" ] [ text "Stuck on a puzzle? Need a hint?" ]
            , p [ class "body-text" ] [ text "Contact Elliot Fiske in the Commons Slack for assistance." ]
            , div [ class "divider-simple" ] []
            , p [ class "text-center mt-6" ]
                [ a [ class "link-gold", href "/hub", onClick (NavigateTo "/hub") ] [ text "Back to Puzzle Hub" ]
                ]
            ]
        ]
