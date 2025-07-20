-- In your treesitter.lua file
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'hiphish/rainbow-delimiters.nvim',
  },
  config = function()
    -- Set up rainbow delimiters
    -- This must be done BEFORE the main treesitter config
    require('rainbow-delimiters.setup').setup()
    require('ts_context_commentstring').setup()

    -- Enable context-aware commenting
    vim.g.skip_ts_context_commentstring_module = true

    require('nvim-treesitter.configs').setup {
      -- A list of parser names, or "all"
      -- (Tip: organizing this alphabetically makes it easier to manage)
      ensure_installed = {
        'bash', 'cmake', 'css', 'dockerfile', 'go', 'gitignore', 'graphql',
        'groovy', 'html', 'java', 'javascript', 'json', 'lua', 'make',
        'markdown', 'markdown_inline', 'python', 'regex', 'sql', 'terraform',
        'toml', 'tsx', 'typescript', 'vim', 'vimdoc', 'yaml',
      },

      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      -- Automatically install missing parsers when entering a buffer
      auto_install = true,

      highlight = {
        enable = true,
        -- Using rainbow-delimiters instead of the built-in rainbow module
        additional_vim_regex_highlighting = false,
      },

      indent = { enable = true },

      -- Enable `nvim-ts-autotag` which works with html, htmldjango, jsx, tsx, etc.
      autotag = {
        enable = true,
      },

      -- Enable `nvim-ts-context-commentstring` for context-aware commenting
      -- context_commentstring = {
      --   enable = true,
      --   enable_autocmd = false,
      -- },
      --
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<M-space>',
        },
      },

      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>A'] = '@parameter.inner',
          },
        },
      },
    }

    -- Your custom filetype associations remain the same
    vim.filetype.add { extension = { tf = 'terraform' } }
    vim.filetype.add { extension = { tfvars = 'terraform' } }
    vim.filetype.add { extension = { pipeline = 'groovy' } }
    vim.filetype.add { extension = { multibranch = 'groovy' } }
  end,
}
