return {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
      require("themery").setup({
        themes = {
        "gruvbox-material",
        "onedark",
        "tokyodark",
        "nord",
        "catppuccin",
        "kanagawa",
        "miasma",
        "eldritch",
        "fluoromachine",
        "rose-pine",
        "makurai",
        },
      })
    end
  }
