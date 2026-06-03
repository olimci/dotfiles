#!/bin/sh

STATE_DIR="${TMPDIR:-/tmp}/sketchybar_media"
ARTWORK_FILE="$STATE_DIR/artwork"
RATE_FILE="$STATE_DIR/rate"
ROTATION_FILE="$STATE_DIR/rotation"
LOCK_DIR="$STATE_DIR/rotate.lock"
ROTATION_STEP=30
ANIMATION_FRAMES=294

mkdir -p "$STATE_DIR"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT HUP INT TERM

artwork_path="$(cat "$ARTWORK_FILE" 2>/dev/null)"
rate="$(cat "$RATE_FILE" 2>/dev/null)"

if [ -z "$artwork_path" ] || [ ! -f "$artwork_path" ] || [ -z "$rate" ] || [ "$rate" = "0" ]; then
  printf '0' > "$ROTATION_FILE"
  sketchybar --set media.cover background.image.rotation=0
  exit 0
fi

rotation="$(cat "$ROTATION_FILE" 2>/dev/null)"
case "$rotation" in
  ''|*[!0-9]*) rotation=0 ;;
esac

if [ "$rotation" -ge 360 ]; then
  rotation=0
  sketchybar --set media.cover background.image.rotation=0
fi

next_rotation=$((rotation + ROTATION_STEP))
target_rotation="$next_rotation"
stored_rotation="$next_rotation"

if [ "$next_rotation" -ge 360 ]; then
  target_rotation=360
  stored_rotation=360
fi

printf '%s' "$stored_rotation" > "$ROTATION_FILE"
sketchybar --animate linear "$ANIMATION_FRAMES" --set media.cover background.image.rotation="$target_rotation"
