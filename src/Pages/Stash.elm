module Pages.Stash exposing (viewFound, viewPuzzle)

import Html exposing (Html, a, div, h1, h2, li, p, span, text, ul)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import PuzzleData
import Types exposing (FrontendMsg(..), PuzzleId(..), StashId(..), StashProgress)


viewPuzzle : StashProgress -> Html FrontendMsg
viewPuzzle stashes =
    let
        allFound =
            stashes.moonshine && stashes.whiskey && stashes.gin && stashes.bourbon && stashes.rum
    in
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ h1 [ class "heading-deco" ] [ text "Smuggler's Stash" ]
            , div [ class "divider-deco" ] []
            , p [ class "body-text" ] [ text "Look for the SHADY place where the LIGHT is found" ]
            , h2 [ class "heading-secondary mt-8" ] [ text "Stashes Found:" ]
            , ul [ class "stash-list" ]
                [ stashItem "Moonshine" stashes.moonshine
                , stashItem "Whiskey" stashes.whiskey
                , stashItem "Gin" stashes.gin
                , stashItem "Bourbon" stashes.bourbon
                , stashItem "Rum" stashes.rum
                ]
            , if allFound then
                div [ class "text-center mt-8" ]
                    [ p [ class "feedback-success" ] [ text ("All stashes found! The number is: " ++ PuzzleData.revealedNumber Puzzle3) ]
                    , a [ class "back-link", href "/hub" ] [ text "Back to Hub" ]
                    ]

              else
                p [ class "text-center mt-6" ] [ a [ class "back-link", href "/hub" ] [ text "Back to Hub" ] ]
            ]
        , div [ class "page-footer" ]
            [ a [ class "page-footer-link", href "/help", onClick (NavigateTo "/help") ] [ text "Need help?" ]
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
                [ div [ class "celebration-icon" ] [ text "✦" ]
                , h1 [ class "celebration-title" ] [ text "You found a stash!" ]
                , div [ class "celebration-icon" ] [ text "✦" ]
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
        , div [ class "page-footer" ]
            [ a [ class "page-footer-link", href "/help", onClick (NavigateTo "/help") ] [ text "Need help?" ]
            ]
        ]
