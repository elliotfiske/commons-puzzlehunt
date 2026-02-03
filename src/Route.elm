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
        , map HelpRoute (s "help")
        , map DebugResetRoute (s "debug-reset")
        ]


parseStashFound : String -> Route
parseStashFound stashName =
    case stashName of
        "jonathans-moonshine" ->
            StashFoundRoute Moonshine

        "jonnys-whiskey" ->
            StashFoundRoute Whiskey

        "josukes-gin" ->
            StashFoundRoute Gin

        "jolenes-bourbon" ->
            StashFoundRoute Bourbon

        "jotaros-rum" ->
            StashFoundRoute Rum

        _ ->
            NotFoundRoute
