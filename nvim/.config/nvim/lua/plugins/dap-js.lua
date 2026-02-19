-- lua/plugins/dap-js.lua
return {
  -- Extend nvim-dap with Node.js/TypeScript debugging support
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function(_, opts)
      -- Let LazyVim set up dap first (this calls the default config)
      -- We need to replicate what LazyVim does, then add our stuff

      local dap = require("dap")

      -- Load mason-nvim-dap if available (from LazyVim)
      if require("lazy.core.config").plugins["mason-nvim-dap.nvim"] then
        pcall(function()
          require("mason-nvim-dap").setup(require("lazy.core.config").plugins["mason-nvim-dap.nvim"].opts or {})
        end)
      end

      -- Set up highlight for stopped line (from LazyVim)
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      -- Set up DAP signs with nice icons (from LazyVim)
      local dap_icons = {
        Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
        Breakpoint = " ",
        BreakpointCondition = " ",
        BreakpointRejected = { " ", "DiagnosticError" },
        LogPoint = ".>",
      }
      for name, sign in pairs(dap_icons) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      -- Set up JSONC support for launch.json (from LazyVim + our extension)
      local vscode = require("dap.ext.vscode")
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
