return {
    {
        'samueljoli/cyberpunk.nvim',
        lazy = false,
        priority = 1000,
        config = function ()
         local fm = require 'cyberpunk'

         fm.setup {
            theme = 'dark',
         }

         vim.cmd.colorscheme 'cyberpunk'
        end
    }
}
