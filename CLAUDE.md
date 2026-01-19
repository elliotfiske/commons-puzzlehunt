# Project Overview
This is the website for a puzzle hunt based out of the SF Commons, a coworking and event space. The puzzles are "speakeasy" themed and revolve around a fictional historical speakeasy that used to be at the site of the Commons.

# Website
This repository is the code for the website. The purpose of the website is to provide an "entry point" to the puzzles, host some of the interactive elements, and serve as a way for participants to check their answers.

## Language
This repository uses the Elm language and the Lamdera runtime. Elm is a type-safe, pure functional language for creating webapps. Lamdera is a runtime for Elm that enables it to have a Frontend and persisted Backend and provides free hosting.

## Testing
Maintaining a robust E2E test suite is important as it allows us to move quickly without accidentally introducing regressions. Lamdera ships with program-test, an E2E test suite that runs in milliseconds but still provides high fidelity to the actual final user experience.