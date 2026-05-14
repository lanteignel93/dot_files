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
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client.supports_method('textDocument/inlayHint') then
          vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        end

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
      'clangd',
      'lua_ls',
      'basedpyright',
      'ruff',
      'jsonls',
      'sqlls',
      'terraformls',
      'yamlls',
      'bashls',
      'dockerls',
      'r_language_server',
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
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      },
    }

    -- Initialize mason.nvim
    require('mason').setup()

    -- Get the capabilities table for nvim-cmp
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    capabilities.offsetEncoding = { 'utf-16' } -- Fix for Clangd crash

    -- CLANGD native configuration (C/C++)
    -- clangd discovers compile_commands.json by walking up from each file,
    -- so we don't pin --compile-commands-dir (it would freeze to nvim's
    -- launch cwd and break when opening files in other projects).
    vim.lsp.config('clangd', {
      cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--header-insertion=iwyu',
        '--completion-style=detailed',
        '--query-driver=/usr/bin/g++,/usr/bin/c++',
      },
      root_dir = vim.fs.root(0, { 'compile_commands.json', '.git' }),
      capabilities = capabilities,
    })

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
        pylsp = function() end,
        pyright = function() end,
        clangd = function() end,
      },
    })
  end,
}
