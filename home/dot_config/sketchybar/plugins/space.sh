#!/bin/sh

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" \
             icon.highlight=on \
             background.color=0xffbfbdb6 \
             background.border_color=0x00000000 \
             background.border_width=1
else
  sketchybar --set "$NAME" \
             icon.highlight=off \
             background.color=0xee080808 \
             background.border_color=0x00000000 \
             background.border_width=0
fi
