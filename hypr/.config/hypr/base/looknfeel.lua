-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

-- Colors. The .conf `$activeBorderColor` variables are now plain Lua values;
-- this module returns them so other files (theme/, looknfeel.lua) can reuse them.
local colors = {
  active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
  inactive_border = "rgba(595959aa)",
}

hl.config({
  -- https://wiki.hypr.land/Configuring/Basics/Variables/#general
  general = {
    gaps_in  = 5,
    gaps_out = 10,

    border_size = 2,

    col = {
      active_border   = colors.active_border,
      inactive_border = colors.inactive_border,
    },

    -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false,

    -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
    allow_tearing = false,

    layout = "dwindle",
  },

  -- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
  decoration = {
    rounding = 0,

    shadow = {
      enabled      = true,
      range        = 2,
      render_power = 3,
      color        = "rgba(1a1a1aee)",
    },

    blur = {
      enabled    = true,
      size       = 2,
      passes     = 2,
      special    = true,
      brightness = 0.60,
      contrast   = 0.75,
    },
  },

  -- https://wiki.hypr.land/Configuring/Basics/Variables/#group
  group = {
    col = {
      border_active   = colors.active_border,
      border_inactive = colors.inactive_border,
      -- 0.56 removed the "-1 = inherit" sentinel, so inherit explicitly
      border_locked_active   = colors.active_border,
      border_locked_inactive = colors.inactive_border,
    },

    groupbar = {
      font_size            = 12,
      font_family          = "monospace",
      font_weight_active   = "ultraheavy",
      font_weight_inactive = "normal",

      indicator_height = 0,
      indicator_gap    = 5,
      height           = 22,
      gaps_in          = 5,
      gaps_out         = 0,

      text_color          = "rgb(ffffff)",
      text_color_inactive = "rgba(ffffff90)",
      col = {
        active   = "rgba(00000040)",
        inactive = "rgba(00000020)",
      },

      gradients                 = true,
      gradient_rounding         = 0,
      gradient_round_only_edges = false,
    },
  },

  -- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
  animations = {
    enabled = true,
  },

  -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
  dwindle = {
    -- pseudotile was removed in Hyprland 0.56 ; the `pseudo` dispatcher (SUPER + P) works without it
    preserve_split = true, -- You probably want this
    force_split    = 2,    -- Always split on the right
  },

  -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
  master = {
    new_status = "master",
  },

  -- https://wiki.hypr.land/Configuring/Basics/Variables/#misc
  misc = {
    disable_hyprland_logo    = true,
    disable_splash_rendering = true,
    focus_on_activate        = true,
    anr_missed_pings         = 3,
  },

  -- https://wiki.hypr.land/Configuring/Basics/Variables/#cursor
  cursor = {
    hide_on_key_press = true,
  },
})

-- Default animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1.0 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = false, speed = 0,    bezier = "ease" })

-- Style Gum confirm to match terminal theme
hl.env("GUM_CONFIRM_PROMPT_FOREGROUND", "6")      -- Cyan
hl.env("GUM_CONFIRM_SELECTED_FOREGROUND", "0")    -- Black
hl.env("GUM_CONFIRM_SELECTED_BACKGROUND", "2")    -- Green
hl.env("GUM_CONFIRM_UNSELECTED_FOREGROUND", "0")  -- Black
hl.env("GUM_CONFIRM_UNSELECTED_BACKGROUND", "8")  -- Dark grey

return colors
