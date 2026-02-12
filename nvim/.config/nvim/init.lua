-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.opt.termguicolors = true
vim.cmd.colorscheme("catppuccin")

-- Map mouse back button to Ctrl+O (jump back)
vim.keymap.set("n", "<X1Mouse>", "<C-o>", { desc = "Jump back" })

-- Map mouse forward button to Ctrl+I (jump forward)
vim.keymap.set("n", "<X2Mouse>", "<C-i>", { desc = "Jump forward" })
