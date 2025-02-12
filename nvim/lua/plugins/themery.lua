return {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
      require("themery").setup({
        themes = {"gruxbox", "onedark", "tokyodark", "nord", "catppuccino", "kanagawa", "miasma"},
      })
    end
  }
