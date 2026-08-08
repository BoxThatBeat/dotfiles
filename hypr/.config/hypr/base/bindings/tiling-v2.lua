-- See https://wiki.hypr.land/Configuring/Basics/Binds/
-- The .conf `bindd` descriptions are now the `description` bind option.

-- Close windows
hl.bind("SUPER + W", hl.dsp.window.close(), { description = "Close window" })
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("omarchy-hyprland-window-close-all"), { description = "Close all windows" })

-- Control tiling
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Toggle window split" }) -- dwindle
hl.bind("SUPER + P", hl.dsp.window.pseudo(), { description = "Pseudo window" })             -- dwindle
hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle window floating/tiling" })
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Full screen" })
hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }), { description = "Tiled full screen" })
hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Full width" })
hl.bind("SUPER + O", hl.dsp.exec_cmd("omarchy-hyprland-window-pop"), { description = "Pop window out (float & pin)" })

-- Move focus with SUPER + arrow keys
hl.bind("SUPER + LEFT",  hl.dsp.focus({ direction = "l" }), { description = "Move window focus left" })
hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "r" }), { description = "Move window focus right" })
hl.bind("SUPER + UP",    hl.dsp.focus({ direction = "u" }), { description = "Move window focus up" })
hl.bind("SUPER + DOWN",  hl.dsp.focus({ direction = "d" }), { description = "Move window focus down" })

-- NOTE: the .conf version bound these by keycode (code:10 .. code:19) for layout
-- independence. Hyprland 0.56.2's Lua bind parser accepts "code:NN" but silently
-- drops the keycode (the bind registers with key="" and keycode=0, so it can never
-- match), so these are bound by key name instead. On the `us` layout configured in
-- base/input.lua the mapping is identical: code:10..19 -> 1..9,0.
-- If a non-QWERTY layout is ever added, revisit this.
for ws = 1, 10 do
  local key = tostring(ws % 10) -- 10 maps to key 0

  -- Switch workspaces with SUPER + [1-9; 0]
  hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = ws }),
    { description = "Switch to workspace " .. ws })

  -- Move active window to a workspace with SUPER + SHIFT + [1-9; 0]
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }),
    { description = "Move window to workspace " .. ws })

  -- Move active window silently to a workspace with SUPER + SHIFT + ALT + [1-9; 0]
  hl.bind("SUPER + SHIFT + ALT + " .. key, hl.dsp.window.move({ workspace = ws, follow = false }),
    { description = "Move window silently to workspace " .. ws })
end

-- Control scratchpad
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("scratchpad"), { description = "Toggle scratchpad" })
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }), { description = "Move window to scratchpad" })

-- TAB between workspaces
hl.bind("SUPER + TAB",         hl.dsp.focus({ workspace = "e+1" }),      { description = "Next workspace" })
hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }),      { description = "Previous workspace" })
hl.bind("SUPER + CTRL + TAB",  hl.dsp.focus({ workspace = "previous" }), { description = "Former workspace" })

-- Move workspaces to other monitors
hl.bind("SUPER + SHIFT + ALT + LEFT",  hl.dsp.workspace.move({ monitor = "l" }), { description = "Move workspace to left monitor" })
hl.bind("SUPER + SHIFT + ALT + RIGHT", hl.dsp.workspace.move({ monitor = "r" }), { description = "Move workspace to right monitor" })

-- Swap active window with the one next to it with SUPER + SHIFT + arrow keys
hl.bind("SUPER + SHIFT + LEFT",  hl.dsp.window.swap({ direction = "l" }), { description = "Swap window to the left" })
hl.bind("SUPER + SHIFT + RIGHT", hl.dsp.window.swap({ direction = "r" }), { description = "Swap window to the right" })
hl.bind("SUPER + SHIFT + UP",    hl.dsp.window.swap({ direction = "u" }), { description = "Swap window up" })
hl.bind("SUPER + SHIFT + DOWN",  hl.dsp.window.swap({ direction = "d" }), { description = "Swap window down" })

-- Cycle through applications on active workspace
hl.bind("ALT + TAB",         hl.dsp.window.cycle_next(),                { description = "Cycle to next window" })
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }), { description = "Cycle to prev window" })
hl.bind("ALT + TAB",         hl.dsp.window.bring_to_top(),              { description = "Reveal active window on top" })
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.bring_to_top(),              { description = "Reveal active window on top" })

-- Resize active window (code:20 = minus, code:21 = equal on the us layout)
hl.bind("SUPER + minus",         hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { description = "Expand window left" })
hl.bind("SUPER + equal",         hl.dsp.window.resize({ x = 100,  y = 0, relative = true }), { description = "Shrink window left" })
hl.bind("SUPER + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { description = "Shrink window up" })
hl.bind("SUPER + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 100,  relative = true }), { description = "Expand window down" })

-- Scroll through existing workspaces with SUPER + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll active workspace forward" })
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Scroll active workspace backward" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Move window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

-- Toggle groups
hl.bind("SUPER + G",       hl.dsp.group.toggle(),                        { description = "Toggle window grouping" })
hl.bind("SUPER + ALT + G", hl.dsp.window.move({ out_of_group = true }),  { description = "Move active window out of group" })

-- Join groups
hl.bind("SUPER + ALT + LEFT",  hl.dsp.window.move({ into_group = "l" }), { description = "Move window to group on left" })
hl.bind("SUPER + ALT + RIGHT", hl.dsp.window.move({ into_group = "r" }), { description = "Move window to group on right" })
hl.bind("SUPER + ALT + UP",    hl.dsp.window.move({ into_group = "u" }), { description = "Move window to group on top" })
hl.bind("SUPER + ALT + DOWN",  hl.dsp.window.move({ into_group = "d" }), { description = "Move window to group on bottom" })

-- Navigate a single set of grouped windows
hl.bind("SUPER + ALT + TAB",         hl.dsp.group.next(), { description = "Next window in group" })
hl.bind("SUPER + ALT + SHIFT + TAB", hl.dsp.group.prev(), { description = "Previous window in group" })

-- Overload lateral window navigation for grouped windows
hl.bind("SUPER + ALT + LEFT",  hl.dsp.group.prev(), { description = "Move grouped window focus left" })
hl.bind("SUPER + ALT + RIGHT", hl.dsp.group.next(), { description = "Move grouped window focus right" })

-- Scroll through a set of grouped windows with SUPER + ALT + scroll
hl.bind("SUPER + ALT + mouse_down", hl.dsp.group.next(), { description = "Next window in group" })
hl.bind("SUPER + ALT + mouse_up",   hl.dsp.group.prev(), { description = "Previous window in group" })

-- Activate window in a group by number (was code:10..code:14)
for i = 1, 5 do
  hl.bind("SUPER + ALT + " .. i, hl.dsp.group.active({ index = i }),
    { description = "Switch to group window " .. i })
end
