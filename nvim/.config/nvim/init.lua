-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.opt.termguicolors = true
vim.cmd.colorscheme("catppuccin")

-- Map mouse back button to Ctrl+O (jump back)
vim.keymap.set("n", "<X1Mouse>", "<C-o>", { desc = "Jump back" })

-- Map mouse forward button to Ctrl+I (jump forward)
vim.keymap.set("n", "<X2Mouse>", "<C-i>", { desc = "Jump forward" })

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

local function set_scroll()
	vim.opt_local.scroll = math.max(1, math.floor(vim.api.nvim_win_get_height(0) / 4))
end

set_scroll()
vim.api.nvim_create_autocmd({ "VimResized", "WinEnter" }, {
	callback = set_scroll,
})
