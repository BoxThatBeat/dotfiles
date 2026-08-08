-- Change the default Omarchy look'n'feel

-- require() is cached, so these just read back the values the modules already applied.
local theme = require("theme.catppuccin")
local base  = require("base.looknfeel")

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({ general = {
--     -- No gaps between windows or borders
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Use master layout instead of dwindle
--     layout = "master",
-- } })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({ decoration = {
--     -- Use round window corners
--     rounding = 8,
-- } })

-- https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
-- hl.config({ layout = {
--     -- Avoid overly wide single-window layouts on wide screens
--     single_window_aspect_ratio = { 1, 1 },
-- } })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#group
-- Hyprland 0.56 removed the "-1 = inherit from col.border_active" sentinel, so
-- locked groups must name a real gradient. Set here rather than in base/ because
-- this file is loaded after theme/, where the active border gets its real value.
hl.config({
  group = {
    col = {
      border_locked_active   = theme.active_border,
      border_locked_inactive = base.inactive_border,
    },
  },
})
