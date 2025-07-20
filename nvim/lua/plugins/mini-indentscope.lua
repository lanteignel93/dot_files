return {
  'echasnovski/mini.indentscope',
  version = false, -- Or use a specific version tag
  config = function()
    -- Set the highlight for the indent scope lines to a subtle color from your theme
    vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = '#404040' })

    -- No extra setup is needed for a minimal look, but you can add options here
    require('mini.indentscope').setup({
      -- Example: Customize the character used for the line
      -- symbol = '│',
    })
  end,
}

