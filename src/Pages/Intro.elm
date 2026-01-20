module Pages.Intro exposing (view)

import Html exposing (Html, button, div, h1, p, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Types exposing (FrontendMsg(..))


view : Html FrontendMsg
view =
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ h1 [ class "heading-deco" ] [ text "The Secret of the Commons" ]
            , div [ class "divider-deco" ] []
            , div [ class "story-block" ]
                [ p [ class "story-text" ] [ text "In the roaring 1920s, this very building housed one of San Francisco's most exclusive speakeasies..." ]
                , p [ class "story-text" ] [ text "Hidden passages, secret codes, and bootlegged spirits were the order of the day." ]
                , p [ class "story-text" ] [ text "Now, decades later, the secrets of the past are waiting to be uncovered." ]
                , p [ class "story-text" ] [ text "Can you crack the codes and unlock the mysteries of the Commons?" ]
                ]
            , div [ class "divider-deco" ] []
            , div [ class "text-center" ]
                [ button [ id "begin-btn", class "btn-brass", onClick ClickedBegin ] [ text "Begin" ]
                ]
            ]
        ]
