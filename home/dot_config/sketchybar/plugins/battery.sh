#!/bin/sh

INFO="$(pmset -g batt)"
CHARGE="$(printf '%s' "$INFO" | grep -Eo '[0-9]+%' | head -n 1 | tr -d '%')"

ICON="!"
LABEL="?"
COLOR=0xffaad84c

if [ -n "$CHARGE" ]; then
  LABEL="${CHARGE}%"
fi

if printf '%s' "$INFO" | grep -q "AC Power"; then
  ICON=""
  COLOR=0xff5ac1fe
elif [ -n "$CHARGE" ] && [ "$CHARGE" -gt 80 ]; then
  ICON=""
elif [ -n "$CHARGE" ] && [ "$CHARGE" -gt 60 ]; then
  ICON=""
  COLOR=0xff95e5cb
elif [ -n "$CHARGE" ] && [ "$CHARGE" -gt 40 ]; then
  ICON=""
  COLOR=0xfffeb454
elif [ -n "$CHARGE" ] && [ "$CHARGE" -gt 20 ]; then
  ICON=""
  COLOR=0xfffe8f40
else
  ICON=""
  COLOR=0xffef7177
fi

if [ -n "$CHARGE" ] && [ "$CHARGE" -lt 10 ]; then
  LABEL="0$LABEL"
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="$LABEL"
