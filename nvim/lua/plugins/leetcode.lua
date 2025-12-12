return {
    "kawre/leetcode.nvim",
    -- cmd = "Leet",
    build = ":TSUpdate html", -- Recommended if you have nvim-treesitter
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    -- This runs *before* the plugin loads, good for autocommands
    init = function()
        -- Autocmd for LeetCode buffers
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "leetcode", "leetcode_desc" }, -- Adjust once you check :set ft
            callback = function()
                -- Disable Treesitter
                pcall(vim.treesitter.stop, 0)

                -- Disable diagnostics in LC buffers
                pcall(vim.diagnostic.disable, 0)

                -- Optional: keep buffers lightweight
                vim.opt_local.swapfile = false
            end,
        })
    end,
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
        ui = {
            -- Try a minimal theme if available
            theme = "minimal",      -- or "dark", "light" depending on plugin support
            code = {
                position = "right", -- or "split", "tab", etc. (simpler layout can feel faster)
            },
            console = {
                position = "bottom", -- "float" can be nice but sometimes heavier
            },
        },
    },
}
