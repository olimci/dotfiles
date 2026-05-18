#!/bin/sh

JQ="/opt/homebrew/bin/jq"
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
POPUP_WIDTH=250

. "$CONFIG_DIR/colors.sh"

current_volume() {
  osascript -e 'output volume of (get volume settings)' 2>/dev/null \
    | awk '/^[0-9]+$/ { print; exit }'
}

collapse_details() {
  drawing="off"
  if [ -x "$JQ" ]; then
    drawing="$(sketchybar --query widgets.volume.bracket | "$JQ" -r '.popup.drawing // "off"')"
  fi

  [ "$drawing" = "on" ] || return 0
  sketchybar --set widgets.volume.bracket popup.drawing=off
  sketchybar --remove '/volume.device\.*/'
}

update_volume() {
  volume="${INFO:-0}"
  case "$volume" in
    ''|*[!0-9]*) volume=0 ;;
  esac
  icon=""

  if [ "$volume" -gt 60 ]; then
    icon=""
  elif [ "$volume" -gt 30 ]; then
    icon=""
  elif [ "$volume" -gt 10 ]; then
    icon=""
  elif [ "$volume" -gt 0 ]; then
    icon=""
  fi

  lead=""
  if [ "$volume" -lt 10 ]; then
    lead="0"
  fi

  sketchybar --set widgets.volume2 label="$icon" \
             --set widgets.volume1 label="${lead}${volume}%" \
             --set widgets.volume.slider slider.percentage="$volume"
}

toggle_details() {
  if [ "$BUTTON" = "right" ]; then
    open /System/Library/PreferencePanes/Sound.prefpane
    return 0
  fi

  drawing="off"
  if [ -x "$JQ" ]; then
    drawing="$(sketchybar --query widgets.volume.bracket | "$JQ" -r '.popup.drawing // "off"')"
  fi

  if [ "$drawing" = "off" ]; then
    sketchybar --set widgets.volume.bracket popup.drawing=on
    current="$(SwitchAudioSource -t output -c | sed 's/[[:space:]]*$//')"
    counter=0

    SwitchAudioSource -a -t output | while IFS= read -r device; do
      [ -n "$device" ] || continue

      color="$WHITE"
      background="$WIDGET_BG"
      border_width=0
      border_color="$TRANSPARENT"
      if [ "$current" = "$device" ]; then
        color="$BLACK"
        background="$WHITE"
        border_width=1
        border_color="$TRANSPARENT"
      fi

      escaped_device="$(printf '%s' "$device" | sed 's/"/\\"/g')"
      sketchybar --add item "volume.device.$counter" popup.widgets.volume.bracket \
                 --set "volume.device.$counter" \
                       width="$POPUP_WIDTH" \
                       align=center \
                       padding_left=10 \
                       padding_right=10 \
                       icon.drawing=off \
                       label="$device" \
                       label.color="$color" \
                       label.align=center \
                       label.max_chars=28 \
                       label.padding_left=8 \
                       label.padding_right=8 \
                       background.color="$background" \
                       background.height=26 \
                       background.corner_radius=13 \
                       background.border_width="$border_width" \
                       background.border_color="$border_color" \
                       click_script="SwitchAudioSource -s \"$escaped_device\" && sketchybar --set '/volume.device\\.[0-9]+$/' label.color=$WHITE background.color=$WIDGET_BG background.border_width=0 background.border_color=$TRANSPARENT --set \"\$NAME\" label.color=$BLACK background.color=$WHITE background.border_width=1 background.border_color=$TRANSPARENT"
      counter=$((counter + 1))
    done
  else
    collapse_details
  fi
}

scroll_volume() {
  delta=""
  modifier=""

  if [ -x "$JQ" ] && printf '%s' "$INFO" | "$JQ" empty >/dev/null 2>&1; then
    delta="$(printf '%s' "$INFO" | "$JQ" -r '.delta // 0')"
    modifier="$(printf '%s' "$INFO" | "$JQ" -r '.modifier // empty')"
  fi

  if [ -z "$delta" ]; then
    delta="$(printf '%s' "$INFO" | sed -n 's/.*delta[=:]\([-0-9.]*\).*/\1/p')"
  fi
  if [ -z "$modifier" ]; then
    modifier="$(printf '%s' "$INFO" | sed -n 's/.*modifier[=:]\([^,} ]*\).*/\1/p')"
  fi

  [ -n "$delta" ] || delta=0
  if [ "$modifier" != "ctrl" ]; then
    delta="$(awk "BEGIN { print $delta * 10.0 }")"
  fi

  osascript -e "set volume output volume (output volume of (get volume settings) + $delta)"
}

case "$SENDER" in
  forced|routine)
    INFO="$(current_volume)"
    update_volume
    ;;
  volume_change) update_volume ;;
  mouse.clicked) toggle_details ;;
  mouse.exited.global) collapse_details ;;
  mouse.scrolled) scroll_volume ;;
esac
