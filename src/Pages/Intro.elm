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
                [ p [ class "story-text" ] [ text "In 1924, this basement wasn't so much a ‘coworking space’ as it was a 'plastered pretense'." ]
                , p [ class "story-text" ] [ text "These days, the SF Commons is filled with people drinking artisanal oat milk and discussing things like ‘synergy,’ but the building still remembers a time when the only thing ‘artisanal’ was the bathtub gin." ]
                , p [ class "story-text" ] [ text "The secrets haven’t gone anywhere; they're simply waiting for a particularly curious individual to uncover them." ]
                ]
            , div [ class "divider-deco" ] []
            , div [ class "hidden sm:block text-center py-6 px-4 my-6 mx-auto max-w-xs border border-[#a69f8f]" ]
                [ p [ class "text-[#a69f8f] text-sm mb-4 leading-relaxed" ]
                    [ text "This experience is best enjoyed on a mobile device. Scan the QR code below to continue on your phone." ]
                , img [ class "w-40 h-40 mx-auto border-2 border-[#a07830]", src "/qr-code-for-desktop.jpg", alt "QR code to open on mobile" ] []
                ]
            , div [ class "text-center" ]
                [ button [ id "begin-btn", class "btn-brass", onClick ClickedBegin ] [ text "Begin" ]
                ]
            ]
        ]
