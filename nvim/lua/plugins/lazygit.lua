return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  keys = {
    { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'Open LazyGit' },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    -- Use a dedicated highlight group for the border for better theme control
    vim.api.nvim_set_hl(0, 'LazyGitBorder', { fg = '#585858' }) -- Muted gray from your darkvoid theme

    require('lazygit').setup({
      -- Use the modern setup function instead of vim.g variables
      floating_window_winblend = 0, -- transparency of floating window
      floating_window_scaling_factor = 0.9,
      floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
      -- Use our custom highlight for the border
      floating_window_border_winhl = 'Normal:LazyGitBorder',
    })

    --
    -- A cleaner way to set up the keybinding
    --
    local function open_lazygit_transparent()
      -- Set the background highlight to NONE just before opening
      vim.api.nvim_set_hl(0, 'LazyGitFloat', { bg = 'NONE' })
      -- Open LazyGit
      print("Attempting to open LazyGit...") -- Add this line for verification
      require('lazygit').open()
    end

    -- Ensure the keymap is set AFTER the setup of lazygit
    vim.schedule(function()
      vim.keymap.set('n', '<leader>lg', open_lazygit_transparent, { desc = 'LazyGit' })
      print("LazyGit keymap <leader>lg set") -- Add this line to confirm keymap setting
    end)
  end,
}
