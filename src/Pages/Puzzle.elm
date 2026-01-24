module Pages.Puzzle exposing (PuzzleConfig, view)

import Html exposing (Html, a, button, div, form, h1, input, p, text)
import Html.Attributes exposing (class, href, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Types exposing (AnswerResult(..), FrontendMsg(..), PuzzleId)


type alias PuzzleConfig =
    { title : String
    , description : String
    , puzzleId : PuzzleId
    }


view : PuzzleConfig -> String -> AnswerResult -> Bool -> Html FrontendMsg
view config inputValue answerResult isComplete =
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ h1 [ class "heading-deco" ] [ text config.title ]
            , div [ class "divider-deco" ] []
            , p [ class "body-text" ] [ text config.description ]
            , if isComplete then
                case answerResult of
                    Correct _ number ->
                        div [ class "text-center mt-8" ]
                            [ p [ class "feedback-success" ] [ text ("Correct! The number is: " ++ number) ]
                            , a [ class "back-link", href "/hub" ] [ text "Back to Hub" ]
                            ]

                    _ ->
                        div [ class "text-center mt-8" ]
                            [ p [ class "feedback-success" ] [ text "Already solved!" ]
                            , a [ class "back-link", href "/hub" ] [ text "Back to Hub" ]
                            ]

              else
                div []
                    [ form [ id "puzzle-form", class "puzzle-form", onSubmit (SubmitAnswer config.puzzleId) ]
                        [ input
                            [ id "password-input"
                            , class "input-paper"
                            , type_ "text"
                            , placeholder "Enter password"
                            , value inputValue
                            , onInput PuzzleInputChanged
                            ]
                            []
                        , button [ id "submit-btn", class "btn-brass w-full", type_ "submit", onClick (SubmitAnswer config.puzzleId) ] [ text "Submit" ]
                        ]
                    , viewAnswerFeedback answerResult config.puzzleId
                    , p [ class "text-center mt-6" ] [ a [ class "back-link", href "/hub" ] [ text "Back to Hub" ] ]
                    ]
            ]
        , div [ class "page-footer" ]
            [ a [ class "page-footer-link", href "/help", onClick (NavigateTo "/help") ] [ text "Need help?" ]
            ]
        ]


viewAnswerFeedback : AnswerResult -> PuzzleId -> Html FrontendMsg
viewAnswerFeedback result currentPuzzle =
    case result of
        NoAnswerYet ->
            text ""

        Incorrect puzzleId ->
            if puzzleId == currentPuzzle then
                p [ class "feedback-error" ] [ text "Incorrect. Try again!" ]

            else
                text ""

        IncorrectButClose _ ->
            text ""

        Correct puzzleId number ->
            if puzzleId == currentPuzzle then
                p [ class "feedback-success" ] [ text ("Correct! The number is: " ++ number) ]

            else
                text ""
