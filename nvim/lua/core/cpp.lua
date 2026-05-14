-- C/C++ buffer helpers — autocmds + LSP-driven keymaps.
-- Loaded from init.lua via `require 'core.cpp'`.

-- ── 1. <leader>oh: jump between source and header via clangd ────────────────
-- Calls clangd's custom `textDocument/switchSourceHeader` request directly so
-- this works regardless of whether nvim-lspconfig registered :LspClangdSwitchSourceHeader.
local function switch_source_header()
    local clients = vim.lsp.get_clients({ bufnr = 0, name = 'clangd' })
    local client = clients[1]
    if not client then
        vim.notify('clangd not attached to this buffer', vim.log.levels.WARN)
        return
    end
    local params = vim.lsp.util.make_text_document_params(0)
    client.request('textDocument/switchSourceHeader', params, function(err, result)
        if err then
            vim.notify('switch source/header: ' .. err.message, vim.log.levels.ERROR)
            return
        end
        if not result or result == vim.NIL or result == '' then
            vim.notify('no matching source/header found', vim.log.levels.WARN)
            return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
    end, 0)
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'c', 'cpp' },
    callback = function(ev)
        vim.keymap.set('n', '<leader>oh', switch_source_header, {
            buffer = ev.buf,
            desc = '[O]pen matching [H]eader/source',
        })
    end,
})

-- ── 2. New-header skeleton: drop a `#pragma once` + blank line ──────────────
-- htaabp-core policy: new headers use `#pragma once` (legacy guards stay as-is).
vim.api.nvim_create_autocmd('BufNewFile', {
    pattern = { '*.hpp', '*.h', '*.hxx', '*.hh' },
    callback = function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '#pragma once',
            '',
            '',
        })
        vim.api.nvim_win_set_cursor(0, { 3, 0 })
    end,
})
