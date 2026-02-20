-- lua/plugins/dap-js.lua
return {
  -- Configure dap-ui layout
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 50, -- Width in columns
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 0.25, -- Height as percentage
          position = "bottom",
        },
      },
    },
  },

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
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Step Out" },
    },
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

      -- Chrome adapter for Angular/browser debugging
      dap.adapters["pwa-chrome"] = {
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
        -- Attach to Chrome via reverse SSH tunnel (chrome --remote-debugging-port=9222 on local)
        {
          type = "pwa-chrome",
          request = "attach",
          name = "Attach to Chrome (port 9222)",
          port = 9222,
          webRoot = get_workspace_folder,
          sourceMaps = true,
          timeout = 30000, -- 30s timeout for remote connections

          resolveSourceMapLocations = { "**/*", "!**/node_modules/**" },
          -- Map webpack paths to local filesystem
          sourceMapPathOverrides = function()
            local ws = get_workspace_folder()
            return {
              ["webpack:///./src/*"] = ws .. "/src/*",
              ["webpack:///src/*"] = ws .. "/src/*",
              ["webpack:///*"] = ws .. "/*",
              ["webpack:///./~/*"] = ws .. "/node_modules/*",
              ["meteor://app/*"] = ws .. "/*",
            }
          end,
          skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
        -- Node.js debugging
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to Node Port (default: 9229)",
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
