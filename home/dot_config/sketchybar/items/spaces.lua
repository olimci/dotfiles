local colors = require("colors")
local settings = require("settings")

local spaces = {}
local space_size = 28

for i = 1, 10 do
  local space = sbar.add("space", "space." .. i, {
    space = i,
    width = space_size,
    icon = {
      font = { family = settings.font.numbers, size = 12 },
      string = i,
      align = "center",
      width = space_size,
      padding_left = 0,
      padding_right = 0,
      color = colors.white,
      highlight_color = colors.black,
    },
    label = { drawing = false },
    padding_right = 0,
    padding_left = 0,
    background = {
      color = colors.widget_bg,
      border_width = 0,
      height = space_size,
      corner_radius = space_size / 2,
      border_color = colors.transparent,
    },
  })

  spaces[i] = space

  if i < 10 then
    sbar.add("item", "space.padding." .. i, {
      position = "left",
      width = settings.group_paddings,
      padding_left = 0,
      padding_right = 0,
      background = { drawing = false },
      icon = { drawing = false },
      label = { drawing = false },
    })
  end

  space:subscribe("space_change", function(env)
    local selected = env.SELECTED == "true"
    space:set({
      icon = { highlight = selected },
      background = {
        color = selected and colors.white or colors.widget_bg,
        border_color = colors.transparent,
        border_width = selected and 1 or 0,
      },
    })
  end)
end
