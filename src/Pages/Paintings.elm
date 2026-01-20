module Pages.Paintings exposing (view)

import Html exposing (Html, a, button, div, form, h1, img, input, p, span, text)
import Html.Attributes exposing (alt, class, href, id, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Types exposing (AnswerResult(..), FrontendMsg(..), PuzzleId(..))


view : String -> AnswerResult -> Bool -> Html FrontendMsg
view inputValue answerResult isComplete =
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ h1 [ class "heading-deco" ] [ text "The Proof is in the Pigment" ]
            , div [ class "divider-deco" ] []
            , p [ class "body-text" ] [ text "Several paintings hang around the Commons. Find them all and spell out the clue to discover the password." ]
            , div [ class "paintings-grid" ]
                [ viewPainting 1
                , viewPainting 2
                , viewPainting 3
                , viewPainting 4
                , viewPainting 5
                ]
            , if isComplete then
                case answerResult of
                    Correct _ number ->
                        div [ class "text-center mt-8" ]
                            [ p [ class "feedback-success" ] [ text ("Correct! The number is: " ++ number) ]
                            , a [ class "link-gold", href "/hub" ] [ text "Back to Hub" ]
                            ]

                    _ ->
                        div [ class "text-center mt-8" ]
                            [ p [ class "feedback-success" ] [ text "Already solved!" ]
                            , a [ class "link-gold", href "/hub" ] [ text "Back to Hub" ]
                            ]

              else
                div []
                    [ form [ id "puzzle-form", class "puzzle-form", onSubmit (SubmitAnswer Puzzle1) ]
                        [ input
                            [ id "password-input"
                            , class "input-paper"
                            , type_ "text"
                            , placeholder "Enter password"
                            , value inputValue
                            , onInput PuzzleInputChanged
                            ]
                            []
                        , button [ id "submit-btn", class "btn-brass w-full", type_ "submit", onClick (SubmitAnswer Puzzle1) ] [ text "Submit" ]
                        ]
                    , viewAnswerFeedback answerResult
                    , p [ class "text-center mt-6" ] [ a [ class "link-gold", href "/hub" ] [ text "Back to Hub" ] ]
                    ]
            ]
        ]


viewPainting : Int -> Html FrontendMsg
viewPainting number =
    div [ class "painting-item" ]
        [ img
            [ src ("/paintings/" ++ String.fromInt number ++ ".JPG")
            , alt ("Painting " ++ String.fromInt number)
            , class "painting-image"
            ]
            []
        , span [ class "painting-label" ] [ text (String.fromInt number) ]
        ]


viewAnswerFeedback : AnswerResult -> Html FrontendMsg
viewAnswerFeedback result =
    case result of
        NoAnswerYet ->
            text ""

        Incorrect puzzleId ->
            if puzzleId == Puzzle1 then
                p [ class "feedback-error" ] [ text "Incorrect. Try again!" ]

            else
                text ""

        Correct puzzleId number ->
            if puzzleId == Puzzle1 then
                p [ class "feedback-success" ] [ text ("Correct! The number is: " ++ number) ]

            else
                text ""
