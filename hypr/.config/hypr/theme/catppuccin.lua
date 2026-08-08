-- Catppuccin theme overrides, applied on top of base/looknfeel.lua.
local colors = {
  active_border = "rgb(c6d0f5)",
}

hl.config({
  general = {
    col = { active_border = colors.active_border },
  },

  group = {
    col = { border_active = colors.active_border },
  },
})

return colors
