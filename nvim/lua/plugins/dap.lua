return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "igorlfs/nvim-dap-view", -- Modern UI replacement
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
        ensure_installed = { "codelldb", "python" },
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
        winbar = {},        -- Adds clickable icons (Step, Stop, etc.) to the top of the buffer
        auto_toggle = true, -- Automatically open/close the view when debugging starts/ends
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
      map("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      map("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      map("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })

      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
      map("n", "<leader>dv", "<cmd>DapViewToggle<cr>", { desc = "DAP: Toggle Modern View" })
      map("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate" })
    end,
  },

  -- Python-specific helper (Keeping the fix for the Mason path)
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      -- Hardcoded path to avoid registry issues
      local py = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(py)
    end,
  },
}
