return {
    {
        "eldritch-theme/eldritch.nvim",
        lazy = false,
        priority = 1000,
        config = function ()
         local fm = require 'eldritch'

         fm.setup {
            glow = true,
            theme = 'eldritch',
            transparent = true,
         }

         vim.cmd.colorscheme 'eldritch'
        end
    }
}
