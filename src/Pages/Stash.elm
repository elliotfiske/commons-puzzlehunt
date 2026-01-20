module Pages.Stash exposing (viewFound, viewPuzzle)

import Html exposing (Html, a, button, div, form, h1, h2, input, li, p, text, ul)
import Html.Attributes exposing (href, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Types exposing (AnswerResult(..), FrontendMsg(..), PuzzleId(..), StashId(..), StashProgress)


viewPuzzle : StashProgress -> String -> AnswerResult -> Bool -> Html FrontendMsg
viewPuzzle stashes inputValue answerResult isComplete =
    div []
        [ h1 [] [ text "Smuggler's Stash" ]
        , p [] [ text "Find all the hidden stashes around the Commons!" ]
        , h2 [] [ text "Stashes Found:" ]
        , ul []
            [ stashItem "Moonshine" stashes.moonshine
            , stashItem "Whiskey" stashes.whiskey
            , stashItem "Gin" stashes.gin
            , stashItem "Bourbon" stashes.bourbon
            , stashItem "Rum" stashes.rum
            ]
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
                [ p [] [ text "Enter the final password:" ]
                , form [ id "stash-form", onSubmit (SubmitAnswer Puzzle3) ]
                    [ input
                        [ id "stash-password-input"
                        , type_ "text"
                        , placeholder "Enter password"
                        , value inputValue
                        , onInput PuzzleInputChanged
                        ]
                        []
                    , button [ id "stash-submit-btn", type_ "submit", onClick (SubmitAnswer Puzzle3) ] [ text "Submit" ]
                    ]
                , viewAnswerFeedback answerResult
                , p [] [ a [ href "/hub" ] [ text "Back to Hub" ] ]
                ]
        ]


stashItem : String -> Bool -> Html FrontendMsg
stashItem name found =
    li []
        [ text
            (name
                ++ ": "
                ++ (if found then
                        "Found!"

                    else
                        "Not found"
                   )
            )
        ]


viewAnswerFeedback : AnswerResult -> Html FrontendMsg
viewAnswerFeedback result =
    case result of
        NoAnswerYet ->
            text ""

        Incorrect Puzzle3 ->
            p [] [ text "Incorrect. Try again!" ]

        Incorrect _ ->
            text ""

        Correct Puzzle3 number ->
            p [] [ text ("Correct! The number is: " ++ number) ]

        Correct _ _ ->
            text ""


viewFound : StashId -> Bool -> Html FrontendMsg
viewFound stashId hasSeenIntro =
    let
        stashName =
            case stashId of
                Moonshine ->
                    "Moonshine"

                Whiskey ->
                    "Whiskey"

                Gin ->
                    "Gin"

                Bourbon ->
                    "Bourbon"

                Rum ->
                    "Rum"
    in
    div []
        [ h1 [] [ text "You found a stash!" ]
        , p [] [ text ("You discovered the " ++ stashName ++ " stash!") ]
        , if hasSeenIntro then
            a [ href "/stash" ] [ text "Back to Smuggler's Stash" ]

          else
            div []
                [ p [] [ text "You've stumbled upon a secret! Start the puzzle hunt to track your progress." ]
                , a [ href "/" ] [ text "Begin the Hunt" ]
                ]
        ]
