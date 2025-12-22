return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/cmp-nvim-lsp',
    { 'j-hui/fidget.nvim', tag = 'v1.4.0', opts = {} },
    'nvim-telescope/telescope.nvim',
    'hrsh7th/nvim-cmp',
  },
  config = function()
    -- 1. DIAGNOSTIC UI (Icons)
    local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end

    -- 2. SHARED ATTACH FUNCTION (Keymaps)
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = ev.buf, desc = 'LSP: ' .. desc })
        end
        local tb = require('telescope.builtin')

        map('gd', tb.lsp_definitions, '[G]oto [D]efinition')
        map('gr', tb.lsp_references, '[G]oto [R]eferences')
        map('gI', tb.lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', tb.lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', tb.lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', tb.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('<leader>dp', vim.diagnostic.goto_prev, '[D]iagnostic [P]revious')
        map('<leader>dn', vim.diagnostic.goto_next, '[D]iagnostic [N]ext')
        map('<leader>de', vim.diagnostic.open_float, 'Show line [D]iagnostics')
      end,
    })

    -- 3. CORE SETUP
    require('mason').setup()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    capabilities.offsetEncoding = { 'utf-16' } -- Fixed the Clangd crash

    -- 4. SERVER LIST & NATIVE CONFIGURATIONS
    -- We define these natively to stop the "junk" stack traces
    
    -- CLANGD (The Fixed version)
    vim.lsp.config('clangd', {
      cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--header-insertion=iwyu',
        '--completion-style=detailed',
        '--query-driver=/usr/bin/g++,/usr/bin/c++',
        '--compile-commands-dir=' .. vim.fn.getcwd(),
      },
      root_dir = vim.fs.root(0, { 'compile_commands.json', '.git' }),
      capabilities = capabilities,
    })

    -- LUA_LS
    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
          diagnostics = { globals = { 'vim' } },
        },
      },
      capabilities = capabilities,
    })

    -- PYLSP
    vim.lsp.config('pylsp', {
      settings = {
        pylsp = {
          plugins = {
            pyflakes = { enabled = false },
            pycodestyle = { enabled = false },
            pylsp_black = { enabled = true },
          },
        },
      },
      capabilities = capabilities,
    })

    -- 5. ENABLE SERVERS
    local servers = { 
      'clangd', 'lua_ls', 'pylsp', 'ruff', 'jsonls', 
      'sqlls', 'terraformls', 'yamlls', 'bashls', 'dockerls' 
    }

    require('mason-lspconfig').setup({ ensure_installed = servers })

    -- Start all servers using the native 0.11 engine
    for _, server in ipairs(servers) do
      vim.lsp.enable(server)
    end

    -- 6. FORMAT ON SAVE
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = vim.api.nvim_create_augroup('UserLspFormat', { clear = true }),
      callback = function(args)
        -- Only format if an LSP with formatting capability is attached
        local clients = vim.lsp.get_clients({ bufnr = args.buf })
        if #clients > 0 then
          vim.lsp.buf.format({
            bufnr = args.buf,
            -- Use a 2000ms timeout for larger C++ files
            timeout_ms = 2000,
            -- Ensure it doesn't try to format with something like bashls if multiple attach
            filter = function(client)
              return client.name ~= "bashls" 
            end,
          })
        end
      end,
    })
  end,
}
