-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
  'lewis6991/gitsigns.nvim',
  -- The event key ensures the plugin loads at the right time
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('gitsigns').setup({
      -- Your sign definitions go inside the setup call
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      -- You can add other options here as well
    })
  end,
}
