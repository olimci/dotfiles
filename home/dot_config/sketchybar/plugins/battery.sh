#!/bin/sh

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
. "$CONFIG_DIR/colors.sh"

INFO="$(pmset -g batt)"
CHARGE="$(printf '%s' "$INFO" | grep -Eo '[0-9]+%' | head -n 1 | tr -d '%')"

ICON="!"
LABEL="?"
COLOR="$GREEN"

if [ -n "$CHARGE" ]; then
  LABEL="${CHARGE}%"
fi

if printf '%s' "$INFO" | grep -q "AC Power"; then
  ICON=""
  COLOR="$SKY"
elif [ -n "$CHARGE" ] && [ "$CHARGE" -gt 80 ]; then
  ICON=""
elif [ -n "$CHARGE" ] && [ "$CHARGE" -gt 60 ]; then
  ICON=""
  COLOR="$TEAL"
elif [ -n "$CHARGE" ] && [ "$CHARGE" -gt 40 ]; then
  ICON=""
  COLOR="$YELLOW"
elif [ -n "$CHARGE" ] && [ "$CHARGE" -gt 20 ]; then
  ICON=""
  COLOR="$ORANGE"
else
  ICON=""
  COLOR="$RED"
fi

if [ -n "$CHARGE" ] && [ "$CHARGE" -lt 10 ]; then
  LABEL="0$LABEL"
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="$LABEL"
