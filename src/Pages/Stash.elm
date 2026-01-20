module Pages.Stash exposing (viewFound, viewPuzzle)

import Html exposing (Html, a, button, div, form, h1, h2, input, li, p, span, text, ul)
import Html.Attributes exposing (class, href, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Types exposing (AnswerResult(..), FrontendMsg(..), PuzzleId(..), StashId(..), StashProgress)


viewPuzzle : StashProgress -> String -> AnswerResult -> Bool -> Html FrontendMsg
viewPuzzle stashes inputValue answerResult isComplete =
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ h1 [ class "heading-deco" ] [ text "Smuggler's Stash" ]
            , div [ class "divider-deco" ] []
            , p [ class "body-text" ] [ text "Find all the hidden stashes around the Commons!" ]
            , h2 [ class "heading-secondary mt-8" ] [ text "Stashes Found:" ]
            , ul [ class "stash-list" ]
                [ stashItem "Moonshine" stashes.moonshine
                , stashItem "Whiskey" stashes.whiskey
                , stashItem "Gin" stashes.gin
                , stashItem "Bourbon" stashes.bourbon
                , stashItem "Rum" stashes.rum
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
                div [ class "mt-8" ]
                    [ p [ class "body-text-muted" ] [ text "Enter the final password:" ]
                    , form [ id "stash-form", class "puzzle-form", onSubmit (SubmitAnswer Puzzle3) ]
                        [ input
                            [ id "stash-password-input"
                            , class "input-paper"
                            , type_ "text"
                            , placeholder "Enter password"
                            , value inputValue
                            , onInput PuzzleInputChanged
                            ]
                            []
                        , button [ id "stash-submit-btn", class "btn-brass w-full", type_ "submit", onClick (SubmitAnswer Puzzle3) ] [ text "Submit" ]
                        ]
                    , viewAnswerFeedback answerResult
                    , p [ class "text-center mt-6" ] [ a [ class "link-gold", href "/hub" ] [ text "Back to Hub" ] ]
                    ]
            ]
        ]


stashItem : String -> Bool -> Html FrontendMsg
stashItem name found =
    li [ class "stash-item" ]
        [ span
            [ class
                (if found then
                    "stash-found"

                 else
                    "stash-not-found"
                )
            ]
            [ text name ]
        , span
            [ class
                (if found then
                    "stash-found"

                 else
                    "stash-not-found"
                )
            ]
            [ text
                (if found then
                    "Found!"

                 else
                    "Not found"
                )
            ]
        ]


viewAnswerFeedback : AnswerResult -> Html FrontendMsg
viewAnswerFeedback result =
    case result of
        NoAnswerYet ->
            text ""

        Incorrect Puzzle3 ->
            p [ class "feedback-error" ] [ text "Incorrect. Try again!" ]

        Incorrect _ ->
            text ""

        Correct Puzzle3 number ->
            p [ class "feedback-success" ] [ text ("Correct! The number is: " ++ number) ]

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
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ div [ class "celebration" ]
                [ div [ class "celebration-icon" ] [ text "\u{2726}" ]
                , h1 [ class "celebration-title" ] [ text "You found a stash!" ]
                , div [ class "celebration-icon" ] [ text "\u{2726}" ]
                , p [ class "body-text mt-6" ] [ text ("You discovered the " ++ stashName ++ " stash!") ]
                , if hasSeenIntro then
                    div [ class "mt-8" ]
                        [ a [ class "btn-brass inline-block", href "/stash" ] [ text "Back to Smuggler's Stash" ]
                        ]

                  else
                    div [ class "mt-8" ]
                        [ p [ class "body-text-muted" ] [ text "You've stumbled upon a secret! Start the puzzle hunt to track your progress." ]
                        , a [ class "btn-brass inline-block mt-4", href "/" ] [ text "Begin the Hunt" ]
                        ]
                ]
            ]
        ]
