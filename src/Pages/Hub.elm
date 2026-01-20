module Pages.Hub exposing (view)

import Html exposing (Html, a, div, h1, h2, p, text)
import Html.Attributes exposing (class, href, id)
import Html.Events exposing (onClick)
import Types exposing (FrontendMsg(..), UserProgress)


view : UserProgress -> Html FrontendMsg
view progress =
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ h1 [ class "heading-deco" ] [ text "Puzzle Hub" ]
            , p [ class "body-text-muted" ] [ text "Find all four numbers to unlock the safe." ]
            , div [ class "divider-simple" ] []
            , div [ class "mt-8" ]
                [ puzzleCard "paintings-link" "The Paintings" "/paintings" progress.puzzle1Complete "7"
                , puzzleCard "ledger-link" "Bootlegger's Ledger" "/ledger" progress.puzzle2Complete "3"
                , puzzleCard "stash-link" "Smuggler's Stash" "/stash" progress.puzzle3Complete "5"
                , puzzleCard "tile-link" "The Hidden Tile" "/tile" progress.puzzle4Complete "7"
                ]
            ]
        ]


puzzleCard : String -> String -> String -> Bool -> String -> Html FrontendMsg
puzzleCard linkId title path isComplete revealedNumber =
    a [ id linkId, class "puzzle-card", href path, onClick (NavigateTo path) ]
        [ h2 [ class "puzzle-card-title" ] [ text title ]
        , if isComplete then
            p [ class "puzzle-status-solved" ] [ text ("Solved! The number is: " ++ revealedNumber) ]

          else
            p [ class "puzzle-status-locked" ] [ text "Not yet solved" ]
        ]
