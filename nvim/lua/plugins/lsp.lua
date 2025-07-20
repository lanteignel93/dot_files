return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Core LSP tooling
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',

    -- nvim-cmp source for LSP
    'hrsh7th/cmp-nvim-lsp',

    -- UI for LSP progress
    { 'j-hui/fidget.nvim', tag = 'v1.4.0', opts = {} },

    -- Explicitly state all dependencies for this config
    'nvim-telescope/telescope.nvim',
    'hrsh7th/nvim-cmp', -- ADDED: The missing dependency
  },
  config = function()
    -- This section adds custom icons for the diagnostic signs in the sign column.
    local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end

    -- This autocommand runs whenever an LSP client attaches to a buffer.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = ev.buf, desc = 'LSP: ' .. desc })
        end

        -- LSP & Diagnostic keymaps
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('<leader>dp', vim.diagnostic.goto_prev, '[D]iagnostic [P]revious')
        map('<leader>dn', vim.diagnostic.goto_next, '[D]iagnostic [N]ext')
        map('<leader>de', vim.diagnostic.open_float, 'Show line [D]iagnostics')
      end,
    })

    -- List of servers to install with Mason
    local servers = {
      'lua_ls',
      'pylsp',
      'ruff',
      -- 'ruff_lsp',
      'jsonls',
      'sqlls',
      'terraformls',
      'yamlls',
      'bashls',
      'dockerls',
    }

    -- Server-specific settings
    local server_settings = {
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = {
              globals = { 'vim' },
            },
          },
        },
      },
      pylsp = {
        settings = {
          pylsp = {
            plugins = {
              pyflakes = { enabled = false },
              pycodestyle = { enabled = false },
              pylsp_mypy = { enabled = false },
              pylsp_black = { enabled = true },
            },
          },
        },
      },
    }

    -- Initialize mason.nvim
    require('mason').setup()

    -- Get the capabilities table for nvim-cmp
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- Corrected setup for mason-lspconfig
    require('mason-lspconfig').setup({
      ensure_installed = servers,
      handlers = {
        -- This default handler runs for every server.
        function(server_name)
          require('lspconfig')[server_name].setup({
            capabilities = capabilities,
            settings = server_settings[server_name],
          })
        end,
      },
    })
  end,
}
