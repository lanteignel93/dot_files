-- Neogen: generate Doxygen/docstring scaffolds from function/class signatures.
-- Triggered manually on a function or class line.
--
-- Note for htaabp-core: the repo style prefers prose paragraphs over @param/@return
-- tag walls, so treat neogen's output as a starting point — trim the tags you don't
-- need. The `///` block prefix and the structure are still useful starts.

return {
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    cmd = { 'Neogen' },
    keys = {
        { '<leader>nd', '<cmd>Neogen<CR>',       desc = '[N]eogen [D]ocstring (auto-detect)' },
        { '<leader>nf', '<cmd>Neogen func<CR>',  desc = '[N]eogen [F]unction docstring' },
        { '<leader>nc', '<cmd>Neogen class<CR>', desc = '[N]eogen [C]lass docstring' },
        { '<leader>nt', '<cmd>Neogen type<CR>',  desc = '[N]eogen [T]ype docstring' },
    },
    opts = {
        enabled = true,
        languages = {
            cpp = { template = { annotation_convention = 'doxygen' } },
            c   = { template = { annotation_convention = 'doxygen' } },
            -- Other languages use their own defaults (Python → pep257, Lua → ldoc, etc.)
        },
    },
}
