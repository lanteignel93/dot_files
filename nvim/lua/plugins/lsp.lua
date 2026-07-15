return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Core LSP tooling
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',

    -- Completion engine (provides LSP capabilities)
    'saghen/blink.cmp',

    -- UI for LSP progress
    { 'j-hui/fidget.nvim', tag = 'v1.4.0', opts = {} },

    -- Explicitly state all dependencies for this config
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    -- This section adds custom icons for the diagnostic signs in the sign column.
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = ' ',
          [vim.diagnostic.severity.WARN] = ' ',
          [vim.diagnostic.severity.HINT] = ' ',
          [vim.diagnostic.severity.INFO] = ' ',
        },
      },
    })

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
        map('<leader>dp', function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, '[D]iagnostic [P]revious')
        map('<leader>dn', function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, '[D]iagnostic [N]ext')
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
    }

    -- mason-lspconfig v2 dropped the `handlers` option: it now enables every
    -- installed server via vim.lsp.enable(), picking up whatever is registered
    -- through vim.lsp.config(). So all per-server settings live here.
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    capabilities.offsetEncoding = { 'utf-16' } -- Fix for Clangd crash

    vim.lsp.config('*', { capabilities = capabilities })

    vim.lsp.config('lua_ls', {
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
    })

    vim.lsp.config('basedpyright', {
      settings = {
        basedpyright = {
          analysis = {
            typeCheckingMode = 'basic',
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = 'openFilesOnly',
          },
        },
      },
    })

    -- CLANGD native configuration (C/C++)
    -- root_markers makes clangd resolve the project root per-buffer by walking
    -- up from each file, so opening files from other projects keeps working.
    vim.lsp.config('clangd', {
      cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--header-insertion=iwyu',
        '--completion-style=detailed',
        '--query-driver=/usr/bin/g++,/usr/bin/c++',
        -- Resolved against nvim's cwd; when the path doesn't exist clangd
        -- falls back to the normal ancestor search, so this is a no-op
        -- outside cmake-preset repos (htaabp-core layout).
        '--compile-commands-dir=build/release',
      },
      root_markers = { 'compile_commands.json', '.git' },
    })

    require('mason').setup()
    require('mason-lspconfig').setup({
      ensure_installed = servers,
    })
  end,
}
