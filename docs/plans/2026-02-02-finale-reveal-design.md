# Finale Reveal Design

## Overview

When all 3 puzzles are complete, the Hub page shows a finale section directing users to the physical lockbox.

## Behavior

**Trigger:** `puzzle1Complete && puzzle2Complete && puzzle3Complete`

**Location:** Top of Hub page content, above the puzzle cards

## Content

**Heading:** "The Code is Yours"

**Body:** "You've uncovered all the secrets. Now claim your reward—the lockbox awaits."

**Image:** `/final-lockbox.jpeg` (no caption)

The combination (J-0-E) is not shown explicitly—users piece it together from the solved puzzle cards visible below.

## Implementation

All changes in `Pages/Hub.elm`:

1. Add `allPuzzlesComplete : UserProgress -> Bool` helper
2. Conditionally render finale section in `view` when all complete
3. Finale section: heading, paragraph, image

Add test in `SmokeTests.elm`:
- Verify finale appears when all puzzles solved
- Verify finale hidden when puzzles incomplete

No new routes, backend changes, or types needed.
