#!/bin/sh

NOWPLAYING="/opt/homebrew/bin/nowplaying-cli"
JQ="/opt/homebrew/bin/jq"
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
STATE_DIR="${TMPDIR:-/tmp}/sketchybar_media"
TEXT_FILE="$STATE_DIR/text"
ARTWORK_FILE="$STATE_DIR/artwork"
APPLIED_ARTWORK_FILE="$STATE_DIR/applied_artwork"
RATE_FILE="$STATE_DIR/rate"
ROTATOR_STATE_FILE="$STATE_DIR/rotator_state"
LOCK_DIR="$STATE_DIR/media.lock"
ARTWORK_RENDER_SIZE=56
ARTWORK_RENDER_SCALE="0.5"

. "$CONFIG_DIR/colors.sh"
mkdir -p "$STATE_DIR"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT HUP INT TERM

set_rotator() {
  desired="$1"
  current="$(cat "$ROTATOR_STATE_FILE" 2>/dev/null)"

  if [ "$current" != "$desired" ]; then
    sketchybar --set media.rotator updates="$desired"
    printf '%s' "$desired" > "$ROTATOR_STATE_FILE"
  fi
}

INFO="$("$NOWPLAYING" get --json title artist playbackRate artworkData 2>/dev/null)"
TITLE="$(printf '%s' "$INFO" | "$JQ" -r '.title // empty')"
ARTIST="$(printf '%s' "$INFO" | "$JQ" -r '.artist // empty')"
RATE="$(printf '%s' "$INFO" | "$JQ" -r '.playbackRate // empty')"

if [ -n "$ARTIST" ] && [ -n "$TITLE" ]; then
  MEDIA_TEXT="$ARTIST - $TITLE"
elif [ -n "$TITLE" ]; then
  MEDIA_TEXT="$TITLE"
else
  MEDIA_TEXT="$(cat "$TEXT_FILE" 2>/dev/null)"
fi

if [ -z "$MEDIA_TEXT" ]; then
  set_rotator off
  sketchybar --set media.cover background.image.rotation=0
  sketchybar --set media.bracket drawing=off \
             --set media.cover drawing=off \
             --set media.text drawing=off popup.drawing=off label.color="$WHITE"
  exit 0
fi

if [ -z "$RATE" ] || [ "$RATE" = "0" ]; then
  TOGGLE_ICON=""
  printf '0' > "$RATE_FILE"
  set_rotator off
  sketchybar --set media.cover background.image.rotation=0
else
  TOGGLE_ICON=""
  printf '%s' "$RATE" > "$RATE_FILE"
  printf '%s' "$MEDIA_TEXT" > "$TEXT_FILE"
  set_rotator on
fi

ARTWORK="$(printf '%s' "$INFO" | "$JQ" -r '.artworkData // empty')"

show_cover_icon() {
  : > "$APPLIED_ARTWORK_FILE"

  sketchybar --set media.cover \
             icon.drawing=on \
             icon="$TOGGLE_ICON" \
             icon.color="$WHITE" \
             background.border_width=0 \
             background.border_color=0x00000000 \
             background.image.drawing=off \
             background.image.rotation=0
}

show_cover_art() {
  artwork_path="$1"

  applied_artwork="$(cat "$APPLIED_ARTWORK_FILE" 2>/dev/null)"
  desired_artwork="${artwork_path}|${ARTWORK_RENDER_SCALE}"
  if [ "$applied_artwork" = "$desired_artwork" ]; then
    return
  fi

  sketchybar --set media.cover \
             icon.drawing=off \
             background.border_width=0 \
             background.border_color=0x00000000 \
             background.image.drawing=on \
             background.image.string="$artwork_path" \
             background.image.scale="$ARTWORK_RENDER_SCALE" \
             background.image.corner_radius=14 \
             background.image.border_width=2 \
             background.image.border_color=0x5995e5cb
  printf '%s' "$desired_artwork" > "$APPLIED_ARTWORK_FILE"
}

if [ -n "$ARTWORK" ]; then
  ARTWORK_HASH="$(printf '%s' "$ARTWORK" | shasum -a 1 | awk '{ print $1 }')"
  ARTWORK_EXT="img"
  case "$ARTWORK" in
    iVBOR*) ARTWORK_EXT="png" ;;
    /9j/*) ARTWORK_EXT="jpg" ;;
  esac
  ARTWORK_SOURCE_PATH="$STATE_DIR/artwork_source_${ARTWORK_HASH}.${ARTWORK_EXT}"
  ARTWORK_PATH="$STATE_DIR/artwork_render${ARTWORK_RENDER_SIZE}_${ARTWORK_HASH}.png"

  if [ ! -f "$ARTWORK_SOURCE_PATH" ]; then
    printf '%s' "$ARTWORK" | base64 -D > "$ARTWORK_SOURCE_PATH" 2>/dev/null
  fi

  if [ ! -f "$ARTWORK_PATH" ] && [ -f "$ARTWORK_SOURCE_PATH" ]; then
    sips -s format png -Z "$ARTWORK_RENDER_SIZE" "$ARTWORK_SOURCE_PATH" --out "$ARTWORK_PATH" >/dev/null 2>&1
  fi

  if [ -f "$ARTWORK_PATH" ]; then
    printf '%s' "$ARTWORK_PATH" > "$ARTWORK_FILE"
    show_cover_art "$ARTWORK_PATH"
  else
    show_cover_icon
  fi
elif [ -f "$ARTWORK_FILE" ]; then
  ARTWORK_PATH="$(cat "$ARTWORK_FILE")"
  if [ -f "$ARTWORK_PATH" ]; then
    show_cover_art "$ARTWORK_PATH"
  else
    show_cover_icon
  fi
else
  show_cover_icon
fi

sketchybar --set media.bracket drawing=on \
           --set media.cover drawing=on \
           --set media.text drawing=on label="$MEDIA_TEXT" \
           --set media.control.toggle icon="$TOGGLE_ICON"
