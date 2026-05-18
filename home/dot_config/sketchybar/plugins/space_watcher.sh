#!/bin/sh

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
JQ="/opt/homebrew/bin/jq"
SPACE_CACHE="${TMPDIR:-/tmp}/sketchybar_space_ids"

[ -x "$JQ" ] || exit 0

space_ids="$(plutil -convert json -o - "$HOME/Library/Preferences/com.apple.spaces.plist" 2>/dev/null \
  | "$JQ" -r '.SpacesDisplayConfiguration["Management Data"].Monitors[]
    | select(.Spaces != null)
    | .Spaces[].ManagedSpaceID' 2>/dev/null)"

[ -n "$space_ids" ] || exit 0

if [ ! -f "$SPACE_CACHE" ] || [ "$(cat "$SPACE_CACHE")" != "$space_ids" ]; then
  printf '%s\n' "$space_ids" > "$SPACE_CACHE"
  sketchybar --reload "$CONFIG_DIR/sketchybarrc"
fi
