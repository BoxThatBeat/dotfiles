-- lua/plugins/dap-js.lua
return {
  -- Persist breakpoints between sessions
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "BufReadPost",
    opts = {
      load_breakpoints_event = { "BufReadPost" },
    },
    keys = {
      { "<leader>db", function() require("persistent-breakpoints.api").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dB", function() require("persistent-breakpoints.api").set_conditional_breakpoint() end, desc = "Conditional Breakpoint" },
      { "<leader>dx", function() require("persistent-breakpoints.api").clear_all_breakpoints() end, desc = "Clear All Breakpoints" },
    },
  },

  -- Node.js/TypeScript debugging support
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")

      local js_debug_path = vim.fn.stdpath("data")
        .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { js_debug_path, "${port}" },
        },
      }

      local function get_workspace_folder()
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
        if vim.v.shell_error == 0 and git_root and git_root ~= "" then
          return git_root
        end
        return vim.fn.getcwd()
      end

      local js_ts_configs = {
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to Port (default: 9229)",
          port = function()
            return tonumber(vim.fn.input("Port: ", "9229"))
          end,
          cwd = get_workspace_folder,
          sourceMaps = true,
          outFiles = function()
            local ws = get_workspace_folder()
            return {
              ws .. "/lib/**/*.js",
              ws .. "/dist/**/*.js",
              ws .. "/build/**/*.js",
              ws .. "/out/**/*.js",
            }
          end,
          resolveSourceMapLocations = function()
            local ws = get_workspace_folder()
            return { ws .. "/**", "!" .. ws .. "/node_modules/**" }
          end,
          skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to Node Process (select pid)",
          processId = require("dap.utils").pick_process,
          cwd = get_workspace_folder,
          sourceMaps = true,
          outFiles = function()
            local ws = get_workspace_folder()
            return {
              ws .. "/lib/**/*.js",
              ws .. "/dist/**/*.js",
              ws .. "/build/**/*.js",
              ws .. "/out/**/*.js",
            }
          end,
          resolveSourceMapLocations = function()
            local ws = get_workspace_folder()
            return { ws .. "/**", "!" .. ws .. "/node_modules/**" }
          end,
          skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
      }

      for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[ft] = js_ts_configs
      end
    end,
  },
}
