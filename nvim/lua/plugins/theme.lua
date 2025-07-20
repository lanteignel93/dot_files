return {
    {
        "aliqyan-21/darkvoid.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("darkvoid").setup({
                transparent = true,
                glow = false,
                show_end_of_buffer = true,
                colors = {
                    -- Core editor colors
                    fg = "#c0c0c0",
                    bg = "#1c1c1c",
                    cursor = "#bdfe58",
                    line_nr = "#404040",
                    visual = "#303030",
                    comment = "#585858",
                    search_highlight = "#5EEEAF",

                    -- Syntax highlighting
                    string = "#E5CCFF",
                    func = "#5EEEAF",
                    kw = "#bdfe58",
                    identifier = "#f1f1f1",
                    type = "#99CCFF",
                    type_builtin = "#99CCFF",
                    operator = "#5EEEAF",
                    bracket = "#e6e6e6",
                    preprocessor = "#4b8902",
                    bool = "#99CCFF",
                    constant = "#b2d8d8",

                    -- Git Gutter colors
                    added = "#baffc9",
                    changed = "#ffffba",
                    removed = "#ffb3ba",

                    -- Completion Menu (Pmenu) colors
                    pmenu_bg = "#1c1c1c",
                    pmenu_sel_bg = "#1bfd9c",
                    pmenu_fg = "#c0c0c0",

                    -- EndOfBuffer color
                    eob = "#3c3c3c",

                    -- Plugin-specific colors
                    border = "#585858", -- Telescope border
                    title = "#bdfe58", -- Telescope title
                    bufferline_selection = "#1bfd9c",

                    -- LSP Diagnostics
                    error = "#dea6a0",
                    warning = "#d6efd8",
                    hint = "#bedc74",
                    info = "#7fa1c3",

                    -- Plugin highlight integration
                    plugins = {
                        gitsigns = true,
                        nvim_cmp = true,
                        treesitter = true,
                        nvimtree = true,
                        telescope = true,
                        lualine = false,
                        bufferline = true,
                        oil = true,
                        whichkey = true,
                        nvim_notify = false, -- Important: disabled for manual override
                    },
                },
            })
            -- Apply the colorscheme
            vim.cmd("colorscheme darkvoid")
        end,
    },
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        config = function()
            require("notify").setup({
                -- This is explicitly set because darkvoid is told not to style notify.
                -- Current: Solid black. Consider '#1c1c1c' for a more integrated look.
                background_colour = "#000000",
            })
        end,
    },
}
