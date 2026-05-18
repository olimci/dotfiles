local colors = require("colors")
local settings = require("settings")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 14.0,
    },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 13.0,
    },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    color = colors.widget_bg,
    height = 28,
    corner_radius = 14,
    border_width = 0,
    border_color = colors.transparent,
  },
  popup = {
    background = {
      border_width = 1,
      corner_radius = 6,
      border_color = colors.popup.border,
      color = colors.popup.bg,
      shadow = { drawing = true },
    },
    blur_radius = 30,
  },
  padding_left = 4,
  padding_right = 4,
  scroll_texts = true,
})
