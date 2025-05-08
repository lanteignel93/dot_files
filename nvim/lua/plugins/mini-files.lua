
-- lua/plugins/mini-files.lua
return {
  "echasnovski/mini.nvim", -- This is the main plugin that contains mini.files and other modules
  -- `version = false` -- Uncomment if you want to use the latest commit from the main branch
  -- `version = "*"` -- Or use this to track the latest stable tag

  -- Optional: mini.icons provides nice icons for files and is often used with mini.files
  dependencies = {
    "echasnovski/mini.icons",
  },

  -- Configuration for the `mini.files` module
  -- This `opts` table will be passed to `require('mini.files').setup()`
  opts = function()
    -- You can require other mini modules here if their setup influences mini.files
    -- For example, ensuring mini.icons is set up if you want to use its icons
    if pcall(require, "mini.icons") then
      require("mini.icons").setup() -- Setup with default options or your custom ones
    end

    return {
      -- Options for mini.files
      -- These are the actual options that will be passed to `mini.files.setup()`
      -- Refer to `:help mini.files-options` for all available options
      windows = {
        preview = true,     -- Show preview window
        width_focus = 50,   -- Width of focused window in columns
        width_nofocus = 15, -- Width of non-focused window in columns
        width_preview = 100, -- Width of preview window in columns
      },
      options = {
        -- Automatically change Neovim's CWD to the `mini.files` window's CWD
        synchronize_cwd = true,
        -- Use `mini.files` as the default file explorer (replaces netrw)
        use_as_default_explorer = true,
      },
      mappings = {
        -- Common mappings (refer to :help mini.files-mappings)
        close       = "q",
        go_in       = "l",
        go_in_plus  = "L",
        go_out      = "h",
        go_out_plus = "H",
        synchronize = "<CR>",
        -- Add more custom mappings here if needed
      },
      -- If you have mini.icons installed and set up,
      -- mini.files might pick it up automatically for icons.
      -- You can also explicitly configure an icon provider:
      content = {
        -- `predraw` and `draw` hooks can be used for extensive customization
        -- Example using mini.icons if it's available
        icon_provider = pcall(require, "mini.icons") and "mini.icons" or nil,
      },
    }
  end,

  -- The `config` function is where you call the setup for the module
  config = function(_, opts)
    -- The `opts` argument here is the table returned by the `opts` function/key above
    require("mini.files").setup(opts)

    -- Add keymaps to open/toggle mini.files
    -- Using <leader>e as an example (e for explorer)
    vim.keymap.set("n", "<leader>e", function()
      require("mini.files").open(vim.loop.cwd(), true) -- Open at current working directory, true for focus
    end, { desc = "Open mini.files (Explorer CWD)" })

    -- Open mini.files at the directory of the current buffer
    vim.keymap.set("n", "<leader>fe", function()
      local current_file_path = vim.api.nvim_buf_get_name(0)
      local current_dir
      if current_file_path and current_file_path ~= "" and vim.fn.filereadable(current_file_path) == 1 then
        current_dir = vim.fn.fnamemodify(current_file_path, ":h") -- Get directory of current file
      else
        current_dir = vim.loop.cwd() -- Fallback to CWD
      end
      require("mini.files").open(current_dir, true)
    end, { desc = "Open mini.files (Current File Dir)" })

    -- You might want a keymap to toggle the explorer if it's already open
    -- or to open it specifically to the side. mini.files itself doesn't have
    -- a single "toggle" function like some other explorers, as it focuses on
    -- opening specific paths. You typically close it with its 'close' mapping (default 'q').
  end,
}
