-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/
-- Since Hyprland 0.55 the config is Lua; the old .conf format goes away in 0.57.

-- Use Omarchy defaults (but don't edit these directly!)
require("base.autostart")
require("base.bindings.media")
require("base.bindings.clipboard")
require("base.bindings.tiling-v2")
require("base.envs")
require("base.looknfeel")
require("base.input")
require("base.windows")
require("theme.catppuccin")

-- Change your own setup in these files (and overwrite any settings from defaults!)
require("monitors")
require("input")
require("bindings")
require("looknfeel")
require("autostart")

-- Add any other personal Hyprland configuration below
-- hl.window_rule({ match = { class = "qemu" }, workspace = "5" })
