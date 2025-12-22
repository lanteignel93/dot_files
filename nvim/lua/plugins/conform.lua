return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' }, -- Run on save
  cmd = { 'ConformInfo' },
  config = function()
    require('conform').setup({
      -- Map of filetypes to formatters
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format', 'black' }, -- Uses ruff first, then black
        cpp = { 'clang-format' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        tsx = { 'prettierd' },
        css = { 'prettierd' },
        html = { 'prettierd' },
        json = { 'prettierd' },
        yaml = { 'prettierd' },
        markdown = { 'prettierd' },
        bash = { 'shfmt' },
      },
      -- This is the key part to enable format on save
      format_on_save = {
        lsp_fallback = false, -- Fallback to LSP if a conform formatter isn't found
        timeout_ms = 500,
      },
    })

    -- Add a keymap to format manually
    vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
      require('conform').format({ async = true, lsp_fallback = true })
    end, { desc = '[F]ormat buffer' })
  end,
}
