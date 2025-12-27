return {
  -- The integration relies on toggleterm.nvim to create the floating terminal
  'akinsho/toggleterm.nvim',
  version = '*',
  lazy = true,

  -- Define the keys here to ensure the plugin loads when these keys are pressed
  keys = {
    -- This calls a function we define in the 'config' block below.
    -- We use a custom namespace 'scooter_integration' to avoid polluting the global scope.
    { '<leader>s', '<cmd>lua scooter_integration.open_default()<CR>', mode = 'n', desc = 'Open Scooter Finder' },
    -- The visual mode keymap is more complex (requires getreg) so it is defined inside 'config'.
  },

  config = function()
    local Terminal = require("toggleterm.terminal").Terminal
    local scooter_term = nil

    -- Create a module to hold the functions called by the keymaps
    local M = {}

    ---@param cmd_override string|nil Optional command string for search functionality
    local function open_scooter(cmd_override)
      -- If a command override is provided (i.e., for searching), we must reset the terminal
      -- instance so it is recreated with the new command.
      if cmd_override then
        if scooter_term and scooter_term:is_open() then
          scooter_term:close()
        end
        scooter_term = nil
      end

      if not scooter_term then
        local cmd_to_run = cmd_override or "scooter"
        scooter_term = Terminal:new({
          cmd = cmd_to_run,
          direction = "float",
          close_on_exit = true,
          on_exit = function()
            scooter_term = nil
          end
        })
      end
      scooter_term:open()
    end

    -- Exposed function for the <leader>s keymap
    M.open_default = function()
      open_scooter(nil)
    end

    -- Export the functions under a unique name for the keymap to require
    -- Note: This assignment is typically handled by the module system, but for clarity
    -- in a single file config, we ensure the function is registered.
    _G.scooter_integration = M

    -- 1. Global function called by the external 'scooter' program to open a file
    _G.EditLineFromScooter = function(file_path, line)
      if scooter_term and scooter_term:is_open() then
        scooter_term:close()
      end

      local current_path = vim.fn.expand("%:p")
      local target_path = vim.fn.fnamemodify(file_path, ":p")

      -- Only open the file if we are not already in it
      if current_path ~= target_path then
        vim.cmd.edit(vim.fn.fnameescape(file_path))
      end

      -- Set the cursor to the correct line (Vim is 1-based indexing)
      vim.api.nvim_win_set_cursor(0, { tonumber(line), 0 })
    end

    -- 2. Global function called by the visual mode keymap to search selected text
    _G.OpenScooterSearchText = function(search_text)
      -- Escape newlines and shell characters for the command
      local escaped_text = vim.fn.shellescape(search_text:gsub("\r?\n", " "))
      local cmd = "scooter --search-text " .. escaped_text

      -- Open (and recreate) the terminal with the search command
      open_scooter(cmd)
    end

    -- Visual mode keymap definition
    vim.keymap.set('v', '<leader>r',
      '"ay<ESC><cmd>lua OpenScooterSearchText(vim.fn.getreg("a"))<CR>',
      { desc = 'Search selected text in scooter' }
    )
  end,
}
