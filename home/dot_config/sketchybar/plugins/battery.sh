#!/bin/sh

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
. "$CONFIG_DIR/colors.sh"

INFO="$(pmset -g batt)"
CHARGE="$(printf '%s' "$INFO" | grep -Eo '[0-9]+%' | head -n 1 | tr -d '%')"
LOW_POWER_MODE="$(pmset -g custom 2>/dev/null | awk '/lowpowermode/ { print $2; exit }')"

ICON="?"
ICON_COLOR="$WHITE"
BACKGROUND_COLOR="$WIDGET_BG"

if printf '%s' "$INFO" | grep -q "AC Power"; then
  ICON="充"
  ICON_COLOR="$BLACK"
  BACKGROUND_COLOR="$GREEN"
elif [ -n "$CHARGE" ]; then
  if [ "$CHARGE" -le 10 ]; then
    ICON="一"
  elif [ "$CHARGE" -le 20 ]; then
    ICON="二"
  elif [ "$CHARGE" -le 30 ]; then
    ICON="三"
  elif [ "$CHARGE" -le 40 ]; then
    ICON="四"
  elif [ "$CHARGE" -le 50 ]; then
    ICON="五"
  elif [ "$CHARGE" -le 60 ]; then
    ICON="六"
  elif [ "$CHARGE" -le 70 ]; then
    ICON="七"
  elif [ "$CHARGE" -le 80 ]; then
    ICON="八"
  elif [ "$CHARGE" -le 90 ]; then
    ICON="九"
  else
    ICON="十"
  fi

  if [ "$LOW_POWER_MODE" = "1" ]; then
    ICON_COLOR="$BLACK"
    BACKGROUND_COLOR="$YELLOW"
  elif [ "$CHARGE" -le 20 ]; then
    ICON_COLOR="$BLACK"
    BACKGROUND_COLOR="$RED"
  fi
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$ICON_COLOR" \
           --set widgets.battery.bracket background.color="$BACKGROUND_COLOR"
