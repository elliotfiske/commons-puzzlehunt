module Pages.Ledger exposing (view)

import Html exposing (Html, a, button, div, form, h1, input, p, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, colspan, href, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Types exposing (AnswerResult(..), FrontendMsg(..), PuzzleId(..))


type alias LedgerEntry =
    { book : String
    , page : Int
    , line : Int
    , word : Int
    , answer : Maybe String -- Nothing means this is the hidden password
    }


ledgerEntries : List LedgerEntry
ledgerEntries =
    [ { book = "Sapiens", page = 12, line = 22, word = 8, answer = Nothing }
    , { book = "Being and Time", page = 197, line = 6, word = 2, answer = Nothing }
    , { book = "Sophie's World", page = 14, line = 8, word = 3, answer = Nothing }
    ]


view : String -> AnswerResult -> Bool -> Html FrontendMsg
view inputValue answerResult isComplete =
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ h1 [ class "heading-deco" ] [ text "Bootlegger's Ledger" ]
            , div [ class "divider-deco" ] []
            , p [ class "body-text" ]
                [ text "The bootlegger kept meticulous records. Use the cipher below with books from the Commons library to decode the secret message." ]
            , div [ class "ledger-container" ]
                [ table [ class "ledger-table" ]
                    [ thead []
                        [ tr []
                            [ th [ class "ledger-header" ] [ text "Book" ]
                            , th [ class "ledger-header" ] [ text "Page" ]
                            , th [ class "ledger-header" ] [ text "Line" ]
                            , th [ class "ledger-header" ] [ text "Word" ]
                            , th [ class "ledger-header" ] [ text "Decoded" ]
                            ]
                        ]
                    , tbody [] (List.map viewLedgerRow ledgerEntries)
                    ]
                ]
            , if isComplete then
                case answerResult of
                    Correct _ number ->
                        div [ class "text-center mt-8" ]
                            [ p [ class "feedback-success" ] [ text ("Correct! One part of the combination is: " ++ number) ]
                            , a [ id "back-to-hub-link", class "back-link", href "/hub", onClick (NavigateTo "/hub") ] [ text "Back to Hub" ]
                            ]

                    _ ->
                        div [ class "text-center mt-8" ]
                            [ p [ class "feedback-success" ] [ text "Already solved!" ]
                            , a [ id "back-to-hub-link", class "back-link", href "/hub", onClick (NavigateTo "/hub") ] [ text "Back to Hub" ]
                            ]

              else
                div []
                    [ p [ class "body-text-muted mt-6" ]
                        [ text "Enter the first word to unlock the ledger:" ]
                    , form [ id "puzzle-form", class "puzzle-form", onSubmit (SubmitAnswer Puzzle2) ]
                        [ input
                            [ id "password-input"
                            , class "input-paper"
                            , type_ "text"
                            , placeholder "Enter the first word..."
                            , value inputValue
                            , onInput PuzzleInputChanged
                            ]
                            []
                        , button [ id "submit-btn", class "btn-brass w-full", type_ "submit", onClick (SubmitAnswer Puzzle2) ] [ text "Submit" ]
                        ]
                    , viewAnswerFeedback answerResult
                    , p [ class "text-center mt-6" ] [ a [ id "back-to-hub-link", class "back-link", href "/hub", onClick (NavigateTo "/hub") ] [ text "Back to Hub" ] ]
                    ]
            ]
        , div [ class "page-footer" ]
            [ a [ class "page-footer-link", href "/help", onClick (NavigateTo "/help") ] [ text "Need help?" ]
            ]
        ]


viewLedgerRow : LedgerEntry -> Html FrontendMsg
viewLedgerRow entry =
    tr [ class "ledger-row" ]
        [ td [ class "ledger-cell ledger-book" ] [ text entry.book ]
        , td [ class "ledger-cell ledger-num" ] [ text (String.fromInt entry.page) ]
        , td [ class "ledger-cell ledger-num" ] [ text (String.fromInt entry.line) ]
        , td [ class "ledger-cell ledger-num" ] [ text (String.fromInt entry.word) ]
        , td [ class "ledger-cell ledger-answer" ]
            [ case entry.answer of
                Just answer ->
                    span [ class "ledger-revealed" ] [ text answer ]

                Nothing ->
                    span [ class "ledger-hidden" ] [ text "???" ]
            ]
        ]


viewAnswerFeedback : AnswerResult -> Html FrontendMsg
viewAnswerFeedback result =
    case result of
        NoAnswerYet ->
            text ""

        Incorrect puzzleId ->
            if puzzleId == Puzzle2 then
                p [ class "feedback-error" ] [ text "Incorrect. Try again!" ]

            else
                text ""

        IncorrectButClose _ ->
            text ""

        Correct puzzleId number ->
            if puzzleId == Puzzle2 then
                p [ class "feedback-success" ] [ text ("Correct! One part of the combination is: " ++ number) ]

            else
                text ""
