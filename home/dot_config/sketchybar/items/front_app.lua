local colors = require("colors")
local settings = require("settings")

local front_app = sbar.add("item", "front_app", {
  display = "active",
  icon = { drawing = false },
  label = {
    color = colors.teal,
    padding_left = 8,
    padding_right = 8,
    font = {
      style = settings.font.style_map["Black"],
      size = 12.0,
    },
  },
  background = {
    color = colors.widget_bg,
    border_color = colors.transparent,
    border_width = 0,
  },
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({ label = { string = env.INFO } })
end)
