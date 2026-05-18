#!/bin/sh

STATE_DIR="${TMPDIR:-/tmp}/sketchybar_media"
RATE_FILE="$STATE_DIR/rate"
mkdir -p "$STATE_DIR"

RATE="$(cat "$RATE_FILE" 2>/dev/null)"
if [ -z "$RATE" ] || [ "$RATE" = "0" ]; then
  sketchybar --set media.control.toggle icon=""
  printf '1' > "$RATE_FILE"
else
  sketchybar --set media.control.toggle icon=""
  printf '0' > "$RATE_FILE"
fi

(
  nowplaying-cli togglePlayPause
  sketchybar --trigger media_refresh
  sleep 0.35
  sketchybar --trigger media_refresh
  sleep 1
  sketchybar --trigger media_refresh
) &
