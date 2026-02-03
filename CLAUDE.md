# Project Overview
This is the website for a puzzle hunt based out of the SF Commons, a coworking and event space. The puzzles are "speakeasy" themed and revolve around a fictional historical speakeasy that used to be at the site of the Commons.

# Puzzles
There are 3 main puzzles in the puzzle hunt. They each result in a character – the goal of the hunt is to unlock a Masterlock safe with a 3-character code (J0E). The "home screen" of the app links out to the main puzzles, and shows if the user has completed them. If the user has completed the puzzles, they will see the number "answer" there.

The app will have basic "persisent storage", based solely on the default stable "session ID" as provided by Lamdera. This means a user's state will persist, but if they change devices or clear cookies their state will be erased. This is acceptable because the user can just re-enter passwords they've previously used to get back to their previous state.

## Introduction
The first time the user visits the site, they will see a short fictional story about how the SF Commons used to be a speakeasy in the 1920s with some doctored "pictures" of Commons locations as a prohibition-era speakeasy. When they hit "Begin" they'll be taken to the main puzzle hub. 

## Puzzle 1: Paintings
There are several paintings around the Commons. This puzzle shows each of the paintings in a particular order, with "blanks" like _ _ _ under each painting.

Each painting will have a Post-it note with letters like ABO on it.

The puzzle is to find each painting and fill in the letters to spell out the final clue, which is "ABOVE THE PULL UP BAR". There is a pull-up bar in the Commons. The solver must look above it to see the final "password" to solve the puzzle, which they will enter into a textbox.

## Puzzle 2: Bootlegger's Ledger
There will be a Book Cipher (3 numbers denoting page, line, word) using books found in the Commons library. The answer will be "LOOK UP GULLIBLE IN THE DICTIONARY". The password for this puzzle will be on a post-it note in a dictionary in the library.

## Puzzle 3: Smuggler's Stash
There will be a series of QR codes hidden around the Commons. Each QR code will go to a link like https://puzzle.lamdera.app/stash/moonshine. The puzzle page will track which QR codes the user has found so far, with a small hint for each one. When the user scans a QR code, it will show a celebratory "you found it!" message and the row for that stash will be marked as "completed" on the puzzle page. If somebody scans a QR code without "starting" the  puzzle hunt, they'll be taken to a screen that says "You've found a secret!" with a link to go to the Introduction.

# Website
This repository is the code for the website. The purpose of the website is to provide an "entry point" to the puzzles, host some of the interactive elements, and serve as a way for participants to check their answers.

Each puzzle will have its own "URL", like https://localhost:8000/paintings, that is linked from the main page.

## Language
This repository uses the Elm language and the Lamdera runtime. Elm is a type-safe, pure functional language for creating webapps. Lamdera is a runtime for Elm that enables it to have a Frontend and persisted Backend and provides free hosting.

## Testing
Maintaining a robust E2E test suite is important as it allows us to move quickly without accidentally introducing regressions. Lamdera ships with program-test, an E2E test suite that runs in milliseconds but still provides high fidelity to the actual final user experience.