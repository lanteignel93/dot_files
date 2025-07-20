return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- Corrected the plugin name here 👇
    "jay-babu/mason-nvim-dap.nvim",

    -- REMOVED the config from here, it will be done in the main config block
    "rcarriga/nvim-dap-ui",

    -- This is a dependency for nvim-dap-ui, so it's good to have.
    "nvim-neotest/nvim-nio",

    -- This is a dependency for Python DAP
    "mfussenegger/nvim-dap-python",
  },
  config = function()
    -- Everything is now inside ONE config function
    local dap = require("dap")
    local dapui = require("dapui")

    -- 👇 ADD THIS BLOCK TO DEFINE CUSTOM SIGNS AND HIGHLIGHTS
    vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#fa1100" }) -- Your darkvoid_red color
    vim.api.nvim_set_hl(0, "DapStopped", { fg = "#bdfe58" })    -- Your darkvoid_lime color

    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "CursorLine", numhl = "" })
    require('dap-python').setup()

    -- 1. Configure mason-nvim-dap
    require("mason-nvim-dap").setup({
      ensure_installed = { "python", "cppdbg" },
      automatic_installation = true,
    })

    -- 2. Configure nvim-dap-ui (moved from its own config block)
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
            { id = "repl", size = 1 },
          },
          size = 10,
          position = "bottom",
        },
      },
      highlights = {
        expand_arrow = "Comment",
        current_line = "CursorLine",
        breakpoint = { fg = "#dea6a0" }, -- darkvoid_red
        stopped = { fg = "#bdfe58" },    -- darkvoid_lime
      },
    })

    -- 3. Setup DAP Listeners to integrate with the UI
    -- This MUST come after dapui.setup()
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
    -- This part of your config was already correct!
    -- dap.adapters.python = {
    --   type = "executable",
    --   command = vim.fn.exepath("python"), -- Using exepath is more robust
    --   args = { "-m", "debugpy.adapter" },
    -- }
    --
    -- dap.configurations.python = {
    --   {
    --     type = "python",
    --     request = "launch",
    --     name = "Launch file",
    --     program = "${file}",
    --     pythonPath = function()
    --       return vim.fn.exepath("python")
    --     end,
    --   },
    -- }

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
