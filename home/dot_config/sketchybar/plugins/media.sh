#!/bin/sh

NOWPLAYING="/opt/homebrew/bin/nowplaying-cli"
JQ="/opt/homebrew/bin/jq"
MAGICK="/opt/homebrew/bin/magick"
STATE_DIR="${TMPDIR:-/tmp}/sketchybar_media"
TEXT_FILE="$STATE_DIR/text"
ARTWORK_FILE="$STATE_DIR/artwork"
RATE_FILE="$STATE_DIR/rate"
ARTWORK_RAW="${TMPDIR:-/tmp}/sketchybar_nowplaying_artwork_raw"

mkdir -p "$STATE_DIR"

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
  sketchybar --set media.bracket drawing=off \
             --set media.cover drawing=off \
             --set media.text drawing=off popup.drawing=off label.color=0xffbfbdb6
  exit 0
fi

if [ -z "$RATE" ] || [ "$RATE" = "0" ]; then
  TOGGLE_ICON=""
  printf '0' > "$RATE_FILE"
else
  TOGGLE_ICON=""
  printf '%s' "$RATE" > "$RATE_FILE"
  printf '%s' "$MEDIA_TEXT" > "$TEXT_FILE"
fi

ARTWORK="$(printf '%s' "$INFO" | "$JQ" -r '.artworkData // empty')"
ARTWORK_SIZE=112
ARTWORK_STROKE_WIDTH=6
ARTWORK_CENTER=$((ARTWORK_SIZE / 2))
ARTWORK_RADIUS=$((ARTWORK_CENTER - ARTWORK_STROKE_WIDTH / 2))
ARTWORK_OUTER_EDGE=$((ARTWORK_CENTER + ARTWORK_RADIUS))

show_cover_icon() {
  sketchybar --set media.cover \
             icon.drawing=on \
             icon="$TOGGLE_ICON" \
             icon.color=0xffbfbdb6 \
             background.border_width=0 \
             background.border_color=0x00000000 \
             background.image.drawing=off
}

show_cover_art() {
  artwork_path="$1"
  sketchybar --set media.cover \
             icon.drawing=off \
             background.border_width=0 \
             background.border_color=0x00000000 \
             background.image.drawing=on \
             background.image.string="$artwork_path" \
             background.image.scale=0.25 \
             background.image.corner_radius=14
}

if [ -n "$ARTWORK" ] && [ -x "$MAGICK" ]; then
  printf '%s' "$ARTWORK" | base64 -D > "$ARTWORK_RAW" 2>/dev/null
  ARTWORK_HASH="$(printf '%s' "$ARTWORK" | shasum -a 1 | awk '{ print $1 }')"
  ARTWORK_PATH="$STATE_DIR/artwork_round${ARTWORK_SIZE}_${ARTWORK_HASH}.png"

  if [ ! -f "$ARTWORK_PATH" ]; then
    "$MAGICK" "$ARTWORK_RAW" \
      -resize "${ARTWORK_SIZE}x${ARTWORK_SIZE}^" \
      -gravity center \
      -extent "${ARTWORK_SIZE}x${ARTWORK_SIZE}" \
      \( -size "${ARTWORK_SIZE}x${ARTWORK_SIZE}" xc:none \
          -fill white \
          -draw "circle ${ARTWORK_CENTER},${ARTWORK_CENTER} ${ARTWORK_OUTER_EDGE},${ARTWORK_CENTER}" \) \
      -alpha off \
      -compose copy_opacity \
      -composite \
      -fill none \
      -stroke black \
      -strokewidth "$ARTWORK_STROKE_WIDTH" \
      -draw "circle ${ARTWORK_CENTER},${ARTWORK_CENTER} ${ARTWORK_OUTER_EDGE},${ARTWORK_CENTER}" \
      "$ARTWORK_PATH" >/dev/null 2>&1
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
           --set media.text drawing=on label=" $MEDIA_TEXT" \
           --set media.control.toggle icon="$TOGGLE_ICON"
