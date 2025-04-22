return {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
      require("themery").setup({
        themes = {
        "gruvbox-material",
        "catppuccin",
        "kanagawa",
        "tokyodark",
        "onedark",
        "nord",
        "miasma",
        "eldritch",
        "fluoromachine",
        "rose-pine",
        "makurai",
        },
      })
    end
  }
