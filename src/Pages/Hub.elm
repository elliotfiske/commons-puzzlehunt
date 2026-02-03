module Pages.Hub exposing (view)

import Html exposing (Html, a, div, h1, h2, img, p, text)
import Html.Attributes exposing (class, href, id, src)
import Html.Events exposing (onClick)
import PuzzleData
import Types exposing (FrontendMsg(..), PuzzleId(..), UserProgress)


allPuzzlesComplete : UserProgress -> Bool
allPuzzlesComplete progress =
    progress.puzzle1Complete && progress.puzzle2Complete && progress.puzzle3Complete


finaleSection : Html FrontendMsg
finaleSection =
    div [ class "finale-section", id "finale-section" ]
        [ h2 [ class "heading-deco" ] [ text "The Code is Yours" ]
        , p [ class "body-text" ] [ text "You've uncovered all the secrets. Now claim your reward—the lockbox awaits." ]
        , img [ src "/final-lockbox.jpeg", class "finale-image" ] []
        , div [ class "divider-simple" ] []
        ]


view : UserProgress -> Html FrontendMsg
view progress =
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ if allPuzzlesComplete progress then
                finaleSection

              else
                text ""
            , h1 [ class "heading-deco" ] [ text "Puzzle Hub" ]
            , p [ class "body-text-muted" ] [ text "Find all three characters to unlock the safe." ]
            , div [ class "divider-simple" ] []
            , div [ class "mt-8" ]
                [ puzzleCard "paintings-link" "The Proof is in the Pigment" "/paintings" progress.puzzle1Complete (PuzzleData.revealedNumber Puzzle1)
                , puzzleCard "ledger-link" "Bootlegger's Ledger" "/ledger" progress.puzzle2Complete (PuzzleData.revealedNumber Puzzle2)
                , puzzleCard "stash-link" "Smuggler's Stash" "/stash" progress.puzzle3Complete (PuzzleData.revealedNumber Puzzle3)
                ]
            ]
        , div [ class "page-footer" ]
            [ a [ class "page-footer-link", href "/help", onClick (NavigateTo "/help") ] [ text "Need help?" ]
            ]
        ]


puzzleCard : String -> String -> String -> Bool -> String -> Html FrontendMsg
puzzleCard linkId title path isComplete revealedNumber =
    a [ id linkId, class "puzzle-card", href path, onClick (NavigateTo path) ]
        [ div [ class "puzzle-card-header" ]
            [ div []
                [ h2 [ class "puzzle-card-title" ] [ text title ]
                , if isComplete then
                    p [ class "puzzle-status-solved" ] [ text "Solved!" ]

                  else
                    p [ class "puzzle-status-locked" ] [ text "Not yet solved" ]
                ]
            , if isComplete then
                div [ class "puzzle-revealed-number" ] [ text revealedNumber ]

              else
                text ""
            ]
        ]
