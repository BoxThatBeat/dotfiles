-- Webcam overlay for screen recording
hl.window_rule({ match = { title = "WebcamOverlay" }, float = true })
hl.window_rule({ match = { title = "WebcamOverlay" }, pin = true })
hl.window_rule({ match = { title = "WebcamOverlay" }, no_initial_focus = true })
hl.window_rule({ match = { title = "WebcamOverlay" }, no_dim = true })
-- was `move 100%-w-40 100%-w-40` -- there's a typo in the original hyprland rule,
-- so window_w (not window_h) on the height param is intentional here.
hl.window_rule({ match = { title = "WebcamOverlay" }, move = { "monitor_w-window_w-40", "monitor_h-window_w-40" } })
