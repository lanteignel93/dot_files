return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      -- Pinned: commits after 2026-04-03 require nvim 0.12 stable for the `update` highlight key
      { "igorlfs/nvim-dap-view", commit = "e57ac4051aa56293e89991ab93bc148de35321ca" },
    },
    config = function()
      local dap = require("dap")
      local dap_view = require("dap-view")

      -- 1) SIGNS & HIGHLIGHTS
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#fa1100" })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#bdfe58" })
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "CursorLine" })

      -- 2) MASON & ADAPTERS
      require("mason").setup()
      local mason_dap = require("mason-nvim-dap")

      mason_dap.setup({
        ensure_installed = { "codelldb" },
        automatic_installation = true,
        handlers = {
          function(config)
            mason_dap.default_setup(config)
          end,
          -- Keep your custom C++ logic for the trading engine
          codelldb = function(config)
            config.adapters = {
              type = "server",
              port = "${port}",
              executable = {
                command = "codelldb",
                args = { "--port", "${port}" },
              },
            }
            mason_dap.default_setup(config)
          end,
        },
      })

      -- 3) DAP VIEW SETUP
      -- This replaces the old dapui.setup()
      dap_view.setup({
        auto_toggle = "keep_terminal", -- panel closes on stop, terminal stays so output is readable
        windows = {
          position = "left",
          size = 0.33, -- ~100 cols ultrawide, ~70 on 1920 -- fits long C++ symbols
          terminal = { position = "below", size = 0.38 },
        },
        winbar = {
          default_section = "scopes", -- locals auto-populate; opens here instead of empty Watches
          controls = { enabled = true }, -- step/continue/terminate buttons in the panel winbar
        },
      })

      -- 4) C++ CONFIGURATION (Build folder search)
      dap.configurations.cpp = {
        {
          name = "Launch (codelldb)",
          type = "codelldb",
          request = "launch",
          program = function()
            local path = vim.fn.getcwd() .. "/build/"
            return vim.fn.input("Path to executable: ", path, "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          -- Use the native (clang/lldb) expression evaluator in the REPL/watches
          -- so `?` handles function calls, methods, casts and enum/namespace `::`
          -- (codelldb's default "simple" dialect does not).
          expressions = "native",
          setupCommands = {
            { text = '-enable-pretty-printing', description = 'enable pretty printing', ignoreFailures = false },
          },
        },
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp

      -- 5) KEYMAPS (F-Keys for speed, leader for views)
      local map = vim.keymap.set
      map("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      map("n", "<F6>", dap.run_to_cursor, { desc = "Debug: Run to Cursor" })
      map("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      map("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      map("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })

      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
      map("n", "<leader>dc", dap.continue, { desc = "DAP: Continue" })
      map("n", "<leader>dv", "<cmd>DapViewToggle<cr>", { desc = "DAP: Toggle Modern View" })
      map("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate" })
      map("n", "<leader>dw", function() require("dap-view").add_expr() end, { desc = "DAP: Watch expr/word under cursor" })
      map("v", "<leader>dw", function() require("dap-view").add_expr() end, { desc = "DAP: Watch selection" })
    end,
  },

  -- Python-specific helper (Keeping the fix for the Mason path)
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")
      local debugpy_py = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(debugpy_py)

      local function get_python_path()
        if vim.env.VIRTUAL_ENV then
          return vim.env.VIRTUAL_ENV .. "/bin/python"
        end
        return "python3"
      end

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch with Arguments",
          program = "${file}",
          args = function()
            local args_str = vim.fn.input("Arguments: ")
            return vim.split(args_str, " +")
          end,
          pythonPath = get_python_path,
        },
        {
          type = "python",
          request = "launch",
          name = "Standard Launch (No Args)",
          program = "${file}",
          pythonPath = get_python_path,
        },
      }
    end,
  },
}
