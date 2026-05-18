local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  background = { drawing = false },
  icon = {
    font = {
      style = settings.font.style_map["Regular"],
      size = 19.0,
    },
  },
  label = { font = { family = settings.font.numbers } },
  update_freq = 180,
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
  sbar.exec("pmset -g batt", function(batt_info)
    local icon = "!"
    local label = "?"

    local found, _, charge = batt_info:find("(%d+)%%")
    if found then
      charge = tonumber(charge)
      label = charge .. "%"
    end

    local color = colors.green
    local charging = batt_info:find("AC Power")

    if charging then
      icon = icons.battery.charging
      color = colors.blue
    elseif found and charge > 80 then
      icon = icons.battery._100
    elseif found and charge > 60 then
      icon = icons.battery._75
      color = colors.teal
    elseif found and charge > 40 then
      icon = icons.battery._50
      color = colors.yellow
    elseif found and charge > 20 then
      icon = icons.battery._25
      color = colors.orange
    else
      icon = icons.battery._0
      color = colors.red
    end

    local lead = ""
    if found and charge < 10 then
      lead = "0"
    end

    battery:set({
      icon = {
        string = icon,
        color = color,
      },
      label = { string = lead .. label },
    })
  end)
end)

sbar.add("bracket", "widgets.battery.bracket", { battery.name }, {
  background = {
    color = colors.widget_bg,
    border_width = 0,
    border_color = colors.transparent,
  },
})

sbar.add("item", "widgets.battery.padding", {
  position = "right",
  width = settings.group_paddings,
  padding_left = 0,
  padding_right = 0,
  background = { drawing = false },
  icon = { drawing = false },
  label = { drawing = false },
})
