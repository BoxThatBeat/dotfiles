-- lua/plugins/dap-js.lua
return {
  -- Show variable values inline while debugging
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {},
  },

  -- Persist breakpoints between sessions
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "BufReadPost", -- Load early so breakpoints are restored
    opts = {
      load_breakpoints_event = { "BufReadPost" },
    },
    keys = {
      { "<leader>db", function() require("persistent-breakpoints.api").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dB", function() require("persistent-breakpoints.api").set_conditional_breakpoint() end, desc = "Conditional Breakpoint" },
      { "<leader>dx", function() require("persistent-breakpoints.api").clear_all_breakpoints() end, desc = "Clear All Breakpoints" },
    },
  },

  -- Extend nvim-dap with Node.js/TypeScript debugging support
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "theHamsta/nvim-dap-virtual-text",
    },
    -- Use opts function to extend without replacing LazyVim's config
    opts = function()
      local dap = require("dap")
      local vscode = require("dap.ext.vscode")

      -- Set up JSONC support for launch.json
      vscode.json_decode = function(str)
        return vim.json.decode(require("plenary.json").json_strip_comments(str))
      end

      -- Map pwa-node to JS/TS filetypes for launch.json auto-detection
      vscode.type_to_filetypes["pwa-node"] = { "javascript", "typescript", "javascriptreact", "typescriptreact" }
      vscode.type_to_filetypes["node"] = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

      -- ============================================
      -- Node.js / TypeScript Debugging Configuration
      -- ============================================

      local js_debug_path = vim.fn.stdpath("data")
        .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

      -- pwa-node adapter (used by vscode-js-debug)
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { js_debug_path, "${port}" },
        },
      }

      -- Alias "node" to "pwa-node" for compatibility
      dap.adapters["node"] = dap.adapters["pwa-node"]

      -- Helper to get workspace folder (prefers git root, falls back to cwd)
      local function get_workspace_folder()
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
        if vim.v.shell_error == 0 and git_root and git_root ~= "" then
          return git_root
        end
        return vim.fn.getcwd()
      end

      -- Default configurations for JavaScript and TypeScript
      local js_ts_configs = {
        -- Attach to a specific port (for apps started with --inspect)
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
        -- Attach to a running Node.js process
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
        -- Launch current file
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch Current File",
          program = "${file}",
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

      -- Apply configs to all JS/TS filetypes
      for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[ft] = js_ts_configs
      end
    end,
  },
}
