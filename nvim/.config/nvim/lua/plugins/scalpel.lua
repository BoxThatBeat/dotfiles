return {
	"wassimk/scalpel.nvim",
	version = "*",
	config = true,
	keys = {
		{
			"<leader>r",
			function()
				require("scalpel").substitute()
			end,
			mode = { "n", "x" },
			desc = "substitute word(s)",
		},
	},
}
