-- Fix splash screen showing in weird places and prevent annoying focus takeovers
hl.window_rule({ match = { class = "^(jetbrains-.*)$", title = "^(splash)$", float = true }, tag = "+jetbrains-splash" })
hl.window_rule({ match = { tag = "jetbrains-splash" }, center = true })
hl.window_rule({ match = { tag = "jetbrains-splash" }, no_focus = true })
hl.window_rule({ match = { tag = "jetbrains-splash" }, border_size = 0 })

-- Center popups/find windows
hl.window_rule({ match = { class = "^(jetbrains-.*)", title = "^()$", float = true }, tag = "+jetbrains" })
hl.window_rule({ match = { tag = "jetbrains" }, center = true })

-- Enabling this makes it possible to provide input in popup dialogs (search window, new file, etc.)
hl.window_rule({ match = { tag = "jetbrains" }, stay_focused = true })
hl.window_rule({ match = { tag = "jetbrains" }, border_size = 0 })

-- For some reason tag:jetbrains does not work for size rule.
-- The old `size >50% >50%` ("at least 50%") has no direct equivalent: the new `size`
-- effect sets an exact size and dropped the `>` minimum prefix. `min_size` is the right
-- semantic, but it is documented as taking plain numbers -- whether it evaluates
-- `monitor_w`-style expressions is NOT verified (the config checker accepts anything here).
-- If this rule is ever re-enabled and does nothing, swap to literal pixels, e.g.
--   min_size = { 960, 540 },
hl.window_rule({
  match    = { class = "^(jetbrains-.*)", title = "^()$", float = true },
  min_size = { "monitor_w*0.5", "monitor_h*0.5" },
})

-- Disable window flicker when autocomplete or tooltips appear
hl.window_rule({ match = { class = "^(jetbrains-.*)$", title = "^(win.*)$", float = true }, no_initial_focus = true })

-- Disable mouse focus
hl.window_rule({ match = { class = "^(jetbrains-.*)$" }, no_follow_mouse = true })
