module Pages.Intro exposing (view)

import Html exposing (Html, button, div, h1, img, p, text)
import Html.Attributes exposing (alt, class, id, src)
import Html.Events exposing (onClick)
import Types exposing (FrontendMsg(..))


view : Html FrontendMsg
view =
    div [ class "page-wrapper" ]
        [ div [ class "page-content" ]
            [ h1 [ class "heading-deco" ] [ text "The Secret of the Commons" ]
            , div [ class "divider-deco" ] []
            , img [ class "intro-image", src "/commons-speakeasy.jpg", alt "The Commons in the 1920s" ] []
            , div [ class "story-block" ]
                [ p [ class "story-text" ] [ text "In 1924, this building wasn't so much a ‘coworking space’ as it was a 'plastered pretense'. It was a time when walls were rarely what they seemed and floorboards had a tendency to be more ‘conveniently hollow’ than ‘strictly structural.’" ]
                , p [ class "story-text" ] [ text "Today, the SF Commons is filled with people drinking artisanal oat milk and discussing things like ‘synergy,’ but the building still remembers a time when the only thing ‘artisanal’ was the bathtub gin. The bricks haven’t forgotten the smell of contraband, nor have they quite forgiven the city for the invention of the spreadsheet." ]
                , p [ class "story-text" ] [ text "The secrets haven’t gone anywhere; they’ve simply been filed under ‘Highly Improbable’ and hidden behind a very specific series of rhythmic knocks. We suggest you start looking—the past is notoriously bad at keeping its own secrets, especially when confronted by someone with a decent set of clues and a suspicious amount of curiosity." ]
                ]
            , div [ class "divider-deco" ] []
            , div [ class "text-center" ]
                [ button [ id "begin-btn", class "btn-brass", onClick ClickedBegin ] [ text "Begin" ]
                ]
            ]
        ]
