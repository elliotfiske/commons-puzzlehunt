module Route exposing (fromUrl)

import Types exposing (Route(..), StashId(..))
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


fromUrl : Url -> Route
fromUrl url =
    parse routeParser url
        |> Maybe.withDefault NotFoundRoute


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map IntroRoute top
        , map HubRoute (s "hub")
        , map PaintingsRoute (s "paintings")
        , map LedgerRoute (s "ledger")
        , map StashRoute (s "stash")
        , map parseStashFound (s "stash" </> string)
        , map TileRoute (s "tile")
        ]


parseStashFound : String -> Route
parseStashFound stashName =
    case stashName of
        "moonshine" ->
            StashFoundRoute Moonshine

        "whiskey" ->
            StashFoundRoute Whiskey

        "gin" ->
            StashFoundRoute Gin

        "bourbon" ->
            StashFoundRoute Bourbon

        "rum" ->
            StashFoundRoute Rum

        _ ->
            NotFoundRoute
