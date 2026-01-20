module Pages.Hub exposing (view)

import Html exposing (Html, a, div, h1, h2, p, text)
import Html.Attributes exposing (href, id)
import Html.Events exposing (onClick)
import Types exposing (FrontendMsg(..), UserProgress)


view : UserProgress -> Html FrontendMsg
view progress =
    div []
        [ h1 [] [ text "Puzzle Hub" ]
        , p [] [ text "Find all four numbers to unlock the safe." ]
        , div []
            [ puzzleCard "paintings-link" "Paintings" "/paintings" progress.puzzle1Complete "7"
            , puzzleCard "ledger-link" "Bootlegger's Ledger" "/ledger" progress.puzzle2Complete "3"
            , puzzleCard "stash-link" "Smuggler's Stash" "/stash" progress.puzzle3Complete "1"
            , puzzleCard "tile-link" "The Hidden Tile" "/tile" progress.puzzle4Complete "9"
            ]
        ]


puzzleCard : String -> String -> String -> Bool -> String -> Html FrontendMsg
puzzleCard linkId title path isComplete revealedNumber =
    div []
        [ h2 []
            [ a [ id linkId, href path, onClick (NavigateTo path) ] [ text title ]
            ]
        , if isComplete then
            p [] [ text ("Solved! The number is: " ++ revealedNumber) ]

          else
            p [] [ text "Not yet solved" ]
        ]
