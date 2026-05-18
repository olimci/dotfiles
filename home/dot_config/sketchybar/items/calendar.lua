local colors = require("colors")
local settings = require("settings")

local cal = sbar.add("item", {
  icon = {
    color = colors.orange,
    padding_left = 8,
    font = {
      style = settings.font.style_map["Black"],
      size = 12.0,
    },
  },
  label = {
    color = colors.teal,
    padding_right = 8,
    width = 49,
    align = "right",
    font = { family = settings.font.numbers },
  },
  position = "right",
  update_freq = 30,
  padding_left = 1,
  padding_right = 1,
  background = {
    color = colors.widget_bg,
    border_color = colors.transparent,
    border_width = 0,
  },
})

sbar.add("bracket", { cal.name }, {
  background = {
    color = colors.transparent,
    height = 28,
    border_width = 0,
    border_color = colors.transparent,
  },
})

sbar.add("item", "calendar.padding", {
  position = "right",
  width = settings.group_paddings,
  padding_left = 0,
  padding_right = 0,
  background = { drawing = false },
  icon = { drawing = false },
  label = { drawing = false },
})

cal:subscribe({ "forced", "routine", "system_woke" }, function()
  cal:set({ icon = os.date("%a. %d %b."), label = os.date("%H:%M") })
end)
