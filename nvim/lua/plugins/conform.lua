return {
  'stevearc/conform.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'ConformInfo' },
  config = function()
    local conform = require 'conform'

    conform.setup {
      -- Map of filetypes to formatters
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format' },
        cpp = { 'clang-format' },
        c = { 'clang-format' },
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

      -- ⭐ Make this a FUNCTION so we can skip formatting when disable_autoformat is set
      format_on_save = function(bufnr)
        -- If you set these, formatting will be skipped
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        -- Skip C/C++ on save: legacy code in htaabp-core mixes naming styles
        -- and the repo policy is "no churn-only reformatting". Use <leader>f
        -- to format explicitly when you do want it.
        local ft = vim.bo[bufnr].filetype
        if ft == 'cpp' or ft == 'c' then
          return
        end
        return {
          lsp_fallback = true, -- Fallback to LSP if a conform formatter isn't found
          timeout_ms = 500,
        }
      end,
    }

    -- Add a keymap to format manually
    vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
      conform.format { async = true, lsp_fallback = true }
    end, { desc = '[F]ormat buffer' })

    -- Format then save
    vim.keymap.set('n', '<leader>w', function()
      conform.format({ async = false, lsp_fallback = true, timeout_ms = 500 })
      vim.cmd 'write'
    end, { desc = 'Format + Save' })

    -- Save without formatting
    vim.keymap.set('n', '<leader>Q', function()
      vim.g.disable_autoformat = true
      vim.cmd 'write'
      vim.g.disable_autoformat = false
    end, { desc = 'Save without formatting' })

    -- Clang-format-diff: format only the lines changed vs HEAD on the current file.
    -- htaabp-core policy is "no churn-only reformatting" of legacy files, so this
    -- is the safe way to format incrementally as you edit them.
    vim.keymap.set('n', '<leader>cf', function()
      local file = vim.fn.expand '%:p'
      if file == '' or vim.fn.filereadable(file) == 0 then
        vim.notify('clang-format-diff: no file on disk', vim.log.levels.WARN)
        return
      end
      local repo = vim.fs.root(file, '.git')
      if not repo then
        vim.notify('clang-format-diff: not in a git repo', vim.log.levels.WARN)
        return
      end
      vim.cmd 'silent! write' -- so the diff reflects on-disk state
      local cmd = string.format(
        'cd %s && git diff -U0 --no-color HEAD -- %s | clang-format-diff -i -p1',
        vim.fn.shellescape(repo),
        vim.fn.shellescape(file)
      )
      local out = vim.fn.system(cmd)
      if vim.v.shell_error ~= 0 then
        vim.notify('clang-format-diff failed:\n' .. out, vim.log.levels.ERROR)
      else
        vim.cmd 'edit' -- reload buffer to pick up changes
        vim.notify('clang-format-diff: changed lines formatted', vim.log.levels.INFO)
      end
    end, { desc = '[C]lang-[F]ormat changed lines (vs HEAD)' })
  end,
}
