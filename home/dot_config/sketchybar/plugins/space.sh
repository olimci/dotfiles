#!/bin/sh

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
. "$CONFIG_DIR/colors.sh"

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" \
             icon.highlight=on \
             background.color="$WHITE" \
             background.border_color="$TRANSPARENT" \
             background.border_width=1
else
  sketchybar --set "$NAME" \
             icon.highlight=off \
             background.color="$WIDGET_BG" \
             background.border_color="$TRANSPARENT" \
             background.border_width=0
fi
