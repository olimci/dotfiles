#!/bin/sh

case "$(date '+%u')" in
  1) weekday_char="月" ;;
  2) weekday_char="火" ;;
  3) weekday_char="水" ;;
  4) weekday_char="木" ;;
  5) weekday_char="金" ;;
  6) weekday_char="土" ;;
  *) weekday_char="日" ;;
esac

sketchybar --set "$NAME" icon="$weekday_char $(date '+%-d-%-m')" label="$(date '+%H:%M')"
