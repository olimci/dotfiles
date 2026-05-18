local colors = require("colors")
local icons = require("icons")

local media_text_width = 158
local media_visible_chars = 21
local media_popup_y_offset = -37
local media_popup_nudge = 24
local media_cover_size = 28
local media_cover_render_size = 112
local media_popup_scale = media_cover_size / media_cover_render_size
local media_control_width = (media_text_width - media_popup_nudge) / 3
local media_refresh_after_action =
"sketchybar --trigger media_refresh; sleep 0.35; sketchybar --trigger media_refresh; sleep 1; sketchybar --trigger media_refresh"
local media_toggle_script = 'STATE_DIR="${TMPDIR:-/tmp}/sketchybar_media"; '
    .. 'RATE_FILE="$STATE_DIR/rate"; mkdir -p "$STATE_DIR"; '
    .. 'RATE="$(cat "$RATE_FILE" 2>/dev/null)"; '
    .. 'if [ -z "$RATE" ] || [ "$RATE" = "0" ]; then '
    .. "sketchybar --set media.control.toggle icon.string='"
    .. icons.media.play_pause
    .. "'; printf '1' > \"$RATE_FILE\"; "
    .. "else sketchybar --set media.control.toggle icon.string='"
    .. icons.media.play
    .. "'; printf '0' > \"$RATE_FILE\"; fi; "
    .. "(nowplaying-cli togglePlayPause; "
    .. media_refresh_after_action
    .. ") &"

local media_script = [[
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
             --set media.text drawing=off popup.drawing=off label.color=]] .. colors.white .. [[
  exit 0
fi

if [ -z "$RATE" ] || [ "$RATE" = "0" ]; then
  TOGGLE_ICON="]] .. icons.media.play .. [["
  printf '0' > "$RATE_FILE"
else
  TOGGLE_ICON="]] .. icons.media.play_pause .. [["
  printf '%s' "$RATE" > "$RATE_FILE"
  printf '%s' "$MEDIA_TEXT" > "$TEXT_FILE"
fi

ARTWORK="$(printf '%s' "$INFO" | "$JQ" -r '.artworkData // empty')"
ARTWORK_SIZE=]] .. media_cover_render_size .. [[;
ARTWORK_STROKE_WIDTH=6
ARTWORK_CENTER=$((ARTWORK_SIZE / 2))
ARTWORK_RADIUS=$((ARTWORK_CENTER - ARTWORK_STROKE_WIDTH / 2 ))
ARTWORK_OUTER_EDGE=$((ARTWORK_CENTER + ARTWORK_RADIUS))
ARTWORK_HOLE_RADIUS=10
ARTWORK_HOLE_EDGE=$((ARTWORK_CENTER + ARTWORK_HOLE_RADIUS))

if [ -n "$ARTWORK" ] && [ -x "$MAGICK" ]; then
  printf '%s' "$ARTWORK" | base64 -D > "$ARTWORK_RAW" 2>/dev/null
  ARTWORK_HASH="$(printf '%s' "$ARTWORK" | shasum -a 1 | awk '{ print $1 }')"
  ARTWORK_PATH="$STATE_DIR/artwork_cd${ARTWORK_SIZE}_${ARTWORK_HASH}.png"

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
        -fill black \
        -stroke black \
        -draw "circle ${ARTWORK_CENTER},${ARTWORK_CENTER} ${ARTWORK_HOLE_EDGE},${ARTWORK_CENTER}" \
        "$ARTWORK_PATH" >/dev/null 2>&1
  fi

  if [ -f "$ARTWORK_PATH" ]; then
    printf '%s' "$ARTWORK_PATH" > "$ARTWORK_FILE"
    sketchybar --set media.cover icon.drawing=off background.border_width=0 background.border_color=]] ..
    colors.transparent ..
    [[ background.image.drawing=on background.image.string="$ARTWORK_PATH" background.image.scale=]] ..
    media_popup_scale .. [[ background.image.corner_radius=14
  else
    sketchybar --set media.cover icon.drawing=on icon.string="$TOGGLE_ICON" icon.color=]] ..
    colors.white ..
    [[ background.border_width=0 background.border_color=]] .. colors.transparent .. [[ background.image.drawing=off
  fi
elif [ -f "$ARTWORK_FILE" ]; then
  ARTWORK_PATH="$(cat "$ARTWORK_FILE")"
  if [ -f "$ARTWORK_PATH" ]; then
    sketchybar --set media.cover icon.drawing=off background.border_width=0 background.border_color=]] ..
    colors.transparent ..
    [[ background.image.drawing=on background.image.string="$ARTWORK_PATH" background.image.scale=]] ..
    media_popup_scale .. [[ background.image.corner_radius=14
  else
    sketchybar --set media.cover icon.drawing=on icon.string="$TOGGLE_ICON" icon.color=]] ..
    colors.white ..
    [[ background.border_width=0 background.border_color=]] .. colors.transparent .. [[ background.image.drawing=off
  fi
else
  sketchybar --set media.cover icon.drawing=on icon.string="$TOGGLE_ICON" icon.color=]] ..
    colors.white ..
    [[ background.border_width=0 background.border_color=]] .. colors.transparent .. [[ background.image.drawing=off
fi

sketchybar --set media.bracket drawing=on \
           --set media.cover drawing=on \
           --set media.text drawing=on label=" $MEDIA_TEXT" \
           --set media.control.toggle icon.string="$TOGGLE_ICON"
]]

local media_watcher = sbar.add("item", "media.watcher", {
    position = "right",
    width = 0,
    padding_left = 0,
    padding_right = 0,
    background = { drawing = false },
    icon = { drawing = false },
    label = { drawing = false },
    updates = true,
    update_freq = 2,
    script = media_script,
})

local media_text = sbar.add("item", "media.text", {
    position = "right",
    drawing = false,
    padding_left = 0,
    padding_right = 0,
    icon = { drawing = false },
    label = {
        width = media_text_width,
        max_chars = media_visible_chars,
        scroll_duration = 360,
        align = "left",
        padding_left = 1,
        padding_right = 2,
        color = colors.white,
    },
    scroll_texts = true,
    background = {
        color = colors.widget_bg,
        border_width = 1,
        border_color = colors.with_alpha(colors.white, 0.16),
        height = 28,
        corner_radius = 14,
    },
    popup = {
        align = "center",
        horizontal = true,
        y_offset = media_popup_y_offset,
        background = {
            color = colors.transparent,
            border_width = 0,
            shadow = { drawing = false },
        },
    },
})

local media_cover = sbar.add("item", "media.cover", {
    position = "right",
    width = media_cover_size,
    drawing = false,
    padding_left = 8,
    padding_right = 8,
    background = {
        image = {
            scale = media_popup_scale,
            drawing = false,
            corner_radius = media_cover_size / 2,
            padding_left = 0,
            padding_right = 0,
        },
        color = colors.widget_bg,
        border_width = 0,
        border_color = colors.transparent,
        height = media_cover_size,
        corner_radius = media_cover_size / 2,
    },
    label = { drawing = false },
    icon = {
        string = icons.media.play_pause,
        drawing = false,
        padding_left = 0,
        padding_right = 0,
        width = media_cover_size,
        align = "center",
    },
})

local media_bracket = sbar.add("bracket", "media.bracket", {
    media_text.name,
    media_cover.name,
}, {
    drawing = false,
    background = {
        color = colors.transparent,
        border_width = 0,
        border_color = colors.transparent,
    },
})

local media_control_spacer = sbar.add("item", "media.control.spacer", {
    position = "popup." .. media_text.name,
    width = media_popup_nudge,
    background = { drawing = false },
    icon = { drawing = false },
    label = { drawing = false },
})

local media_control_back = sbar.add("item", "media.control.back", {
    position = "popup." .. media_text.name,
    width = media_control_width,
    background = { drawing = false },
    icon = {
        string = icons.media.back,
        color = colors.white,
        align = "center",
        padding_left = 0,
        padding_right = 0,
    },
    label = { drawing = false },
    click_script = "(nowplaying-cli previous; " .. media_refresh_after_action .. ") &",
})

local media_control_toggle = sbar.add("item", "media.control.toggle", {
    position = "popup." .. media_text.name,
    width = media_control_width,
    background = { drawing = false },
    icon = {
        string = icons.media.play_pause,
        color = colors.white,
        align = "center",
        padding_left = 0,
        padding_right = 0,
    },
    label = { drawing = false },
    click_script = media_toggle_script,
})

local media_control_forward = sbar.add("item", "media.control.forward", {
    position = "popup." .. media_text.name,
    width = media_control_width,
    background = { drawing = false },
    icon = {
        string = icons.media.forward,
        color = colors.white,
        align = "center",
        padding_left = 0,
        padding_right = 0,
    },
    label = { drawing = false },
    click_script = "(nowplaying-cli next; " .. media_refresh_after_action .. ") &",
})

local hide_generation = 0

local function show_media_controls()
    hide_generation = hide_generation + 1
    media_text:set({
        label = { color = colors.transparent },
        popup = { drawing = true },
    })
end

local function hide_media_controls()
    media_text:set({
        label = { color = colors.white },
        popup = { drawing = false },
    })
end

local function schedule_hide_media_controls()
    hide_generation = hide_generation + 1
    local generation = hide_generation
    sbar.exec("sleep 0.12", function()
        if generation == hide_generation then hide_media_controls() end
    end)
end

media_text:subscribe("mouse.entered", show_media_controls)
media_control_spacer:subscribe("mouse.entered", show_media_controls)
media_control_back:subscribe("mouse.entered", show_media_controls)
media_control_toggle:subscribe("mouse.entered", show_media_controls)
media_control_forward:subscribe("mouse.entered", show_media_controls)

media_text:subscribe("mouse.exited", schedule_hide_media_controls)
media_control_spacer:subscribe("mouse.exited", schedule_hide_media_controls)
media_control_back:subscribe("mouse.exited", schedule_hide_media_controls)
media_control_toggle:subscribe("mouse.exited", schedule_hide_media_controls)
media_control_forward:subscribe("mouse.exited", schedule_hide_media_controls)

media_watcher:subscribe({ "forced", "routine", "system_woke" }, function()
    sbar.exec(media_script)
end)

sbar.add("event", "media_refresh")
media_watcher:subscribe("media_refresh", function()
    sbar.exec(media_script)
end)

sbar.exec(media_script)
