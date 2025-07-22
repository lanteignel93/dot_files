return {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html", -- Recommended if you have nvim-treesitter
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    opts = {
        -- This sets the default language when you open the plugin
        lang = "cpp",

        -- This table holds settings FOR EACH language
        languages = {
            cpp = {
                -- Add this format table to control clang-format
                format = {
                    style = {
                        BasedOnStyle = "LLVM",
                        IndentWidth = 4,
                        TabWidth = 4,
                        UseTab = "Never",
                    },
                },
            },
            -- You could add configs for other languages here
            -- python = { ... },
        },
    },
}
