# Puzzle Hunt v1 Design

Focus: Function only, no styling.

## Data Model

### Backend State

```elm
type alias BackendModel =
    { userProgress : Dict SessionId UserProgress
    }

type alias UserProgress =
    { hasSeenIntro : Bool
    , puzzle1Complete : Bool
    , puzzle2Complete : Bool
    , puzzle3Stashes : StashProgress
    , puzzle3Complete : Bool
    , puzzle4Complete : Bool
    }

type alias StashProgress =
    { moonshine : Bool
    , whiskey : Bool
    , gin : Bool
    , bourbon : Bool
    , rum : Bool
    }
```

### Type Definitions

```elm
type PuzzleId = Puzzle1 | Puzzle2 | Puzzle3 | Puzzle4

type StashId = Moonshine | Whiskey | Gin | Bourbon | Rum
```

### Hardcoded Answers

Each puzzle has:
- A password (what the user enters)
- A number answer (revealed on correct password)

Stored as constants in the backend.

## Routing

```elm
type Route
    = IntroRoute           -- /
    | HubRoute             -- /hub
    | PaintingsRoute       -- /paintings
    | LedgerRoute          -- /ledger
    | StashRoute           -- /stash (puzzle page)
    | StashFoundRoute StashId  -- /stash/moonshine (QR scan landing)
    | TileRoute            -- /tile (puzzle 4)
    | NotFoundRoute
```

### Route Behavior

| Route | hasSeenIntro = False | hasSeenIntro = True |
|-------|---------------------|---------------------|
| `/` | Shows intro story | Redirects to `/hub` |
| `/hub` | Redirects to `/` | Shows puzzle grid |
| `/stash/:id` | "You found a secret!" + link to intro | Marks stash found + celebration |

## Frontend/Backend Communication

### On Connect

1. Backend receives `ClientConnected SessionId ClientId`
2. Backend looks up `Dict SessionId UserProgress`
3. Backend sends `InitialState UserProgress` to that client

### Messages

```elm
type ToBackend
    = MarkIntroSeen
    | SubmitPuzzleAnswer PuzzleId String
    | MarkStashFound StashId

type ToFrontend
    = InitialState UserProgress
    | PuzzleAnswerResult PuzzleId (Maybe String)  -- Nothing = wrong, Just "7" = correct
    | StashMarked StashId
```

## Frontend State

```elm
type AnswerResult
    = NoAnswerYet
    | Incorrect PuzzleId
    | Correct PuzzleId String  -- includes the revealed number

type alias FrontendModel =
    { key : Navigation.Key
    , route : Route
    , userProgress : Maybe UserProgress  -- Nothing until backend responds
    , puzzleInput : String
    , lastAnswerResult : AnswerResult
    }
```

### Behavior Notes

- `puzzleInput` clears when navigating to a different puzzle page
- `lastAnswerResult` resets to `NoAnswerYet` when navigating to a different puzzle
- While `userProgress == Nothing`, show "Loading..."

## File Structure

```
src/
  Types.elm         -- All shared types (Route, PuzzleId, StashId, UserProgress, messages)
  Frontend.elm      -- App init, update, routing logic
  Backend.elm       -- Progress storage, answer validation
  Pages/
    Intro.elm       -- Intro view
    Hub.elm         -- Hub view
    Puzzle.elm      -- Shared puzzle page view (reused for all 4)
    Stash.elm       -- Stash puzzle + StashFound views
```

### Shared Puzzle.elm

All 4 puzzles have the same structure:
- Flavor text/description
- Password input field
- Submit button
- Result feedback (incorrect / correct with number)
- Back to hub link

Pass puzzle-specific content (title, description) as parameters.

## Testing (program-test)

Key scenarios:
- First visit -> sees intro -> clicks Begin -> lands on hub
- Returning visit -> skips intro -> lands on hub
- Submit wrong password -> shows "Incorrect"
- Submit correct password -> shows number, hub updates with completion
- Scan QR while not started -> sees "found a secret" message with link to intro
- Scan QR while started -> marks stash found, shows celebration
