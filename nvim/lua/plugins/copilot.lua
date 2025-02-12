return {
    "github/copilot.vim",
    config = function()
      -- Optionally configure copilot.vim here
      vim.g.copilot_no_maps = true
      vim.api.nvim_set_keymap("i", "<C-a>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
    end,
}
