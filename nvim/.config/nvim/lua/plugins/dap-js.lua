-- lua/plugins/dap-js.lua
return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			-- this plugin loads launch.json automatically
			{ "folke/neoconf.nvim", opts = {} },
		},
		opts = function()
			local dap = require("dap")
			local vscode = require("dap.ext.vscode")

			-- enable JSONC support (comments + trailing commas)
			vscode.json_decode = function(str)
				return vim.json.decode(require("plenary.json").json_strip_comments(str))
			end

			vscode.type_to_filetypes["pwa-node"] = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

			-- still need the adapter definition
			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = {
						vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
						"${port}",
					},
				},
			}
		end,
	},
}
