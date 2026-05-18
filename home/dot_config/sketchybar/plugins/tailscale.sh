#!/bin/sh

JQ="/opt/homebrew/bin/jq"
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
POPUP_WIDTH=196
MAX_PEERS=6

. "$CONFIG_DIR/colors.sh"

tailscale_bin() {
  if command -v tailscale >/dev/null 2>&1; then
    command -v tailscale
  elif [ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]; then
    printf '%s\n' /Applications/Tailscale.app/Contents/MacOS/Tailscale
  fi
}

clear_peers() {
  sketchybar --remove '/tailscale\.peer\..*/' >/dev/null 2>&1
}

set_status() {
  sketchybar --set tailscale.status label="$1" icon.color="$2" background.border_color="$3"
}

copy_script_for_ip() {
  escaped_ip="$(printf '%s' "$1" | sed 's/"/\\"/g')"
  printf 'printf %%s "%s" | pbcopy' "$escaped_ip"
}

add_peer() {
  index="$1"
  name="$2"
  ip="$3"
  online="$4"

  icon="○"
  icon_color="$POPUP_BORDER"
  if [ "$online" = "true" ]; then
    icon="●"
    icon_color="$TEAL"
  fi

  click_script=""
  if [ -n "$ip" ]; then
    click_script="$(copy_script_for_ip "$ip")"
  fi

  sketchybar --add item "tailscale.peer.$index" popup.widgets.tailscale \
             --set "tailscale.peer.$index" \
                   width="$POPUP_WIDTH" \
                   align=left \
                   padding_left=6 \
                   padding_right=6 \
                   icon="$icon" \
                   icon.color="$icon_color" \
                   icon.font="$FONT_TEXT:Regular:10.0" \
                   icon.padding_left=8 \
                   icon.padding_right=6 \
                   icon.y_offset=1 \
                   label="$name" \
                   label.color="$WHITE" \
                   label.font="$FONT_TEXT:Medium:12.0" \
                   label.max_chars=18 \
                   label.padding_right=8 \
                   label.y_offset=1 \
                   background.color="$WIDGET_BG" \
                   background.height=24 \
                   background.corner_radius=12 \
                   background.border_width=0 \
                   background.border_color="$TRANSPARENT" \
                   click_script="$click_script"
}

add_peer_summary() {
  label="$1"
  sketchybar --add item tailscale.peer.summary popup.widgets.tailscale \
             --set tailscale.peer.summary \
                   width="$POPUP_WIDTH" \
                   align=center \
                   padding_left=6 \
                   padding_right=6 \
                   icon.drawing=off \
                   label="$label" \
                   label.color="$POPUP_BORDER" \
                   label.font="$FONT_TEXT:Medium:11.0" \
                   label.align=center \
                   label.y_offset=1 \
                   background.drawing=off
}

toggle_popup() {
  drawing="off"
  if [ -x "$JQ" ]; then
    drawing="$(sketchybar --query widgets.tailscale | "$JQ" -r '.popup.drawing // "off"')"
  fi

  if [ "$drawing" = "on" ]; then
    sketchybar --set widgets.tailscale popup.drawing=off
  else
    sketchybar --set widgets.tailscale popup.drawing=on
  fi
}

open_app() {
  open -a Tailscale >/dev/null 2>&1
}

update_status() {
  TS="$(tailscale_bin)"
  if [ -z "$TS" ] || [ ! -x "$JQ" ]; then
    sketchybar --set "$NAME" icon.color="$RED" label="off"
    clear_peers
    set_status "missing cli" "$RED" "$RED"
    return 0
  fi

  INFO="$("$TS" status --json 2>/dev/null)"
  BACKEND="$(printf '%s' "$INFO" | "$JQ" -r '.BackendState // empty' 2>/dev/null)"

  if [ "$BACKEND" != "Running" ]; then
    sketchybar --set "$NAME" icon.color="$RED" label="off"
    clear_peers
    set_status "${BACKEND:-stopped}" "$RED" "$RED"
    return 0
  fi

  IP="$(printf '%s' "$INFO" | "$JQ" -r '.TailscaleIPs[0] // empty')"
  EXIT_ACTIVE="$(printf '%s' "$INFO" | "$JQ" -r '.Self.ExitNode // false')"
  HEALTH_COUNT="$(printf '%s' "$INFO" | "$JQ" -r '.Health | length')"

  label="on"
  color="$TEAL"
  status="connected"

  if [ "$EXIT_ACTIVE" = "true" ]; then
    label="ex"
    color="$ORANGE"
    status="exit: $IP"
  elif [ "$HEALTH_COUNT" -gt 0 ] 2>/dev/null; then
    label="!"
    color="$YELLOW"
    status="warning: $IP"
  elif [ -n "$IP" ]; then
    status="connected: $IP"
  fi

  sketchybar --set "$NAME" icon.color="$color" label="$label"
  set_status "$status" "$color" "$color"

  clear_peers
  peers="$(printf '%s' "$INFO" | "$JQ" -r --argjson max "$MAX_PEERS" '
    [.Peer[]? | {
      name: (.HostName // .DNSName // "unknown"),
      ip: (.TailscaleIPs[0] // ""),
      online: (.Online // false),
      active: (.Active // false)
    }]
    | sort_by((.online | not), (.active | not), .name)
    | .[:$max]
    | to_entries[]
    | [.key, .value.name, .value.ip, .value.online]
    | @tsv
  ')"

  if [ -z "$peers" ]; then
    add_peer_summary "no peers"
    return 0
  fi

  printf '%s\n' "$peers" | while IFS="$(printf '\t')" read -r index name peer_ip online; do
    [ -n "$name" ] || continue
    add_peer "$index" "$name" "$peer_ip" "$online"
  done

  peer_count="$(printf '%s' "$INFO" | "$JQ" -r '[.Peer[]?] | length')"
  if [ "$peer_count" -gt "$MAX_PEERS" ] 2>/dev/null; then
    hidden_count=$((peer_count - MAX_PEERS))
    add_peer_summary "+$hidden_count more"
  fi
}

case "$SENDER" in
  mouse.clicked)
    if [ "$BUTTON" = "right" ]; then
      open_app
    else
      toggle_popup
    fi
    ;;
  *) update_status ;;
esac
