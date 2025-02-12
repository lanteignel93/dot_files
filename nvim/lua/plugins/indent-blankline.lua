return {
  {
    'lukas-reineke/indent-blankline.nvim',
    opts = {
      scope = {
        show_start = true,
        show_end = true,
        show_exact_scope = true,
      },
    },
    config = function(_, opts)
      -- paste the hooks code here
      -- change the setup() call to:
      require("ibl").setup(opts)
    end
  }
}
