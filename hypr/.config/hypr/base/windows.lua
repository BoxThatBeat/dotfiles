-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more
-- hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Just dash of opacity by default
hl.window_rule({ match = { class = ".*" }, opacity = "0.97 0.9" })

-- Fix some dragging issues with XWayland
-- hl.window_rule({
--   match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
--   no_focus = true,
-- })

-- App-specific tweaks
require("base.apps")
