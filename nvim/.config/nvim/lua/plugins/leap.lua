return {
  -- 1. KILL the Flash Treesitter mappings
  {
    "folke/flash.nvim",
    -- This ensures that even if the plugin is technically 'enabled',
    -- the keys are stripped away.
    keys = {
      { "s", mode = { "n", "x", "o" }, false },
      { "S", mode = { "n", "x", "o" }, false },
    },
  },
  {
    url = "https://codeberg.org/andyg/leap.nvim",
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "Leap Forward" },
      { "S", mode = { "n", "x", "o" }, desc = "Leap Backward" },
    },
    opts = {},
    config = function()
      local leap = require("leap")
      leap.add_default_mappings()
      leap.opts.case_sensitive = true
      -- Force Leap to take the keys
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
      vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
    end,
  },
  { "ggandor/flit.nvim", enabled = false },
}
