#!/bin/bash
# Generates an Elm module with a CSS version hash for cache busting
# Uses a hash of input.css content so version only changes when CSS changes

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

INPUT_CSS="$PROJECT_DIR/src/input.css"

if [ -f "$INPUT_CSS" ]; then
    VERSION=$(cat "$INPUT_CSS" | shasum | cut -c1-8)
else
    VERSION=$(date +%s)
fi

cat > "$PROJECT_DIR/src/CssVersion.elm" << EOF
module CssVersion exposing (version)

{-| Auto-generated CSS version for cache busting. Do not edit manually.
-}


version : String
version =
    "$VERSION"
EOF

echo "Generated CssVersion.elm with version: $VERSION"
