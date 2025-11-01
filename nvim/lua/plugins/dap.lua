return {
  -- 1. nvim-dap-python: Separated to apply the LuaRocks fix AND isolate setup
  {
    "mfussenegger/nvim-dap-python",
    -- Remove redundant dependencies here, keep it clean
    opts = {
      rocks = {
        enabled = false,
      },
    },
    -- New: Isolate the setup call here.
    config = function()
      -- This ensures dap-python is configured right after it is loaded.
      require("dap-python").setup()
    end,
  },

  -- 2. MAIN DAP BLOCK
  "mfussenegger/nvim-dap",
  dependencies = {
    "jay-babu/mason-nvim-dap.nvim",
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio", -- dependency for dap-ui/dap
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- Define custom signs and highlights (Theme: dark_void)
    vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#fa1100" })
    vim.api.nvim_set_hl(0, "DapStopped", { fg = "#bdfe58" })

    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "CursorLine", numhl = "" })

    -- !!! REMOVED: require('dap-python').setup() - Redundant with mason-nvim-dap

    -- 1. Configure mason-nvim-dap
    require("mason-nvim-dap").setup({
      ensure_installed = { "python", "cppdbg" },
      automatic_installation = true,
    })

    -- 2. Configure nvim-dap-ui
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
          size = 20,
          position = "bottom",
        },
      },
      highlights = {
        expand_arrow = "Comment",
        current_line = "CursorLine",
        breakpoint = { fg = "#dea6a0" },
        stopped = { fg = "#bdfe58" },
      },
    })

    -- 3. Setup DAP Listeners
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- 4. Define your adapters and configurations
    dap.configurations.cpp = {
      {
        name = "Launch file",
        type = "cppdbg",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtEntry = false,
      },
    }

    -- 5. Set your keymaps
    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP: Continue" })
    vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP: Step Over" })
    vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP: Step Into" })
    vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "DAP: Step Out" })
    vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })
    vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP: Run Last" })
    vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })
  end,
}
