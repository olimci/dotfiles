#!/bin/sh

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
STATE_DIR="${TMPDIR:-/tmp}/sketchybar_media"
GENERATION_FILE="$STATE_DIR/hide_generation"

. "$CONFIG_DIR/colors.sh"
mkdir -p "$STATE_DIR"

next_generation() {
  generation="$(cat "$GENERATION_FILE" 2>/dev/null)"
  generation=$((generation + 1))
  printf '%s' "$generation" > "$GENERATION_FILE"
  printf '%s' "$generation"
}

case "$SENDER" in
  mouse.entered)
    next_generation >/dev/null
    sketchybar --set media.text label.color=0x00000000 popup.drawing=on
    ;;
  mouse.exited)
    generation="$(next_generation)"
    (
      sleep 0.12
      current="$(cat "$GENERATION_FILE" 2>/dev/null)"
      if [ "$current" = "$generation" ]; then
        sketchybar --set media.text label.color="$WHITE" popup.drawing=off
      fi
    ) &
    ;;
esac
