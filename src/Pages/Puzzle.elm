module Pages.Puzzle exposing (view)

import Html exposing (Html, a, button, div, form, h1, input, p, text)
import Html.Attributes exposing (href, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Types exposing (AnswerResult(..), FrontendMsg(..), PuzzleId(..))


type alias PuzzleConfig =
    { title : String
    , description : String
    , puzzleId : PuzzleId
    }


view : PuzzleConfig -> String -> AnswerResult -> Bool -> Html FrontendMsg
view config inputValue answerResult isComplete =
    div []
        [ h1 [] [ text config.title ]
        , p [] [ text config.description ]
        , if isComplete then
            case answerResult of
                Correct _ number ->
                    div []
                        [ p [] [ text ("Correct! The number is: " ++ number) ]
                        , a [ href "/hub" ] [ text "Back to Hub" ]
                        ]

                _ ->
                    div []
                        [ p [] [ text "Already solved!" ]
                        , a [ href "/hub" ] [ text "Back to Hub" ]
                        ]

          else
            div []
                [ form [ id "puzzle-form", onSubmit (SubmitAnswer config.puzzleId) ]
                    [ input
                        [ id "password-input"
                        , type_ "text"
                        , placeholder "Enter password"
                        , value inputValue
                        , onInput PuzzleInputChanged
                        ]
                        []
                    , button [ id "submit-btn", type_ "submit", onClick (SubmitAnswer config.puzzleId) ] [ text "Submit" ]
                    ]
                , viewAnswerFeedback answerResult config.puzzleId
                , p [] [ a [ href "/hub" ] [ text "Back to Hub" ] ]
                ]
        ]


viewAnswerFeedback : AnswerResult -> PuzzleId -> Html FrontendMsg
viewAnswerFeedback result currentPuzzle =
    case result of
        NoAnswerYet ->
            text ""

        Incorrect puzzleId ->
            if puzzleId == currentPuzzle then
                p [] [ text "Incorrect. Try again!" ]

            else
                text ""

        Correct puzzleId number ->
            if puzzleId == currentPuzzle then
                p [] [ text ("Correct! The number is: " ++ number) ]

            else
                text ""
