module Pages.Thanks exposing (view)

import Html exposing (Html, a, div, h1, p, text)
import Html.Attributes exposing (class, href, target)


view : Html msg
view =
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ h1 [ class "heading-deco" ] [ text "Thanks for Playing!" ]
            , div [ class "divider-deco" ] []
            , p [ class "body-text" ] [ text "We hope you enjoyed the puzzle hunt!" ]
            , p [ class "body-text" ] [ text "Your feedback helps us improve future hunts. Please take a moment to share your thoughts:" ]
            , div [ class "text-center mt-8" ]
                [ a
                    [ class "btn-brass inline-block"
                    , href "https://forms.gle/TBE9Z2jE1cMfJYKy8"
                    , target "_blank"
                    ]
                    [ text "Share Your Feedback" ]
                ]
            , div [ class "divider-simple mt-8" ] []
            , p [ class "text-center mt-6" ]
                [ a [ class "link-gold", href "/hub" ] [ text "Back to Puzzle Hub" ]
                ]
            ]
        ]
