-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Use system clipboard for all yank/delete/paste operations
vim.opt.clipboard = "unnamedplus"

-- Always treat the directory nvim was launched in as the project root.
-- Default LazyVim spec is { "lsp", { ".git", "lua" }, "cwd" }, which makes
-- pickers/explorer jump into a submodule's .git when you open a file inside it.
vim.g.root_spec = { "cwd" }
