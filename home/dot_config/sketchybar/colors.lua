return {
  black = 0xff080808,
  white = 0xffbfbdb6,
  red = 0xffef7177,
  green = 0xffaad84c,
  blue = 0xff5ac1fe,
  yellow = 0xfffeb454,
  orange = 0xfffe8f40,
  magenta = 0xffd2a6fe,
  teal = 0xff95e5cb,
  cyan = 0xff39bae5,
  grey = 0xff8a8986,
  transparent = 0x00000000,

  bar = {
    bg = 0x00000000,
    border = 0xff1b4a6e,
  },
  popup = {
    bg = 0xf00d1016,
    border = 0xff3f4043,
  },
  bg1 = 0xff1f2127,
  bg2 = 0xff2d2f34,
  widget_bg = 0xee080808,
  surface = 0xff0d1016,
  border = 0xff3f4043,
  muted = 0xff545557,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
