module Pages.Intro exposing (view)

import Html exposing (Html, button, div, h1, p, text)
import Html.Attributes exposing (id)
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
        , button [ id "begin-btn", onClick ClickedBegin ] [ text "Begin" ]
        ]