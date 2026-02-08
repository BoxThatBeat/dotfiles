return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- add more languages here
    vim.list_extend(opts.ensure_installed, {
      "html",
      "css",
      "tsx",
      "typescript",
      "lua",
      "yaml",
      "markdown",
      "markdwon_inline",
    })
  end,
}
