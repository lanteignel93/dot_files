return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- 1) SIGNS & HIGHLIGHTS
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#fa1100" })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#bdfe58" })
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "CursorLine", numhl = "" })

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
          -- Customizing codelldb for better C++ integration
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

      -- 3) DAP UI SETUP
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.33 },
              { id = "breakpoints", size = 0.33 },
              { id = "stacks",      size = 0.33 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
      })

      -- Auto-open/close UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- 4) C++ CONFIGURATION (Specifically for your project)
      dap.configurations.cpp = {
        {
          name = "Launch (codelldb)",
          type = "codelldb",
          request = "launch",
          program = function()
            -- Forces the search to start in your build folder as seen in image_f73f6d.jpg
            local path = vim.fn.getcwd() .. "/build/"
            return vim.fn.input("Path to executable: ", path, "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          -- This is critical for showing the contents of std::string, std::vector, etc.
          setupCommands = {
            {
              text = '-enable-pretty-printing',
              description = 'enable pretty printing',
              ignoreFailures = false
            },
          },
        },
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp

      -- 5) KEYMAPS (Standard leader keys + Fast F-Keys)
      local map = vim.keymap.set
      map("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      map("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      map("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      map("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })

      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
      map("n", "<leader>dc", dap.continue, { desc = "DAP: Continue" })
      map("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate" })
      map("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })
    end,
  },

  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap", "williamboman/mason.nvim" },
    config = function()
      local registry = require("mason-registry")
      local pkg = registry.get_package("debugpy")
      if pkg:is_installed() then
        local py = pkg:get_install_path() .. "/venv/bin/python"
        require("dap-python").setup(py)
      else
        require("dap-python").setup("python3")
      end
    end,
  },
}
