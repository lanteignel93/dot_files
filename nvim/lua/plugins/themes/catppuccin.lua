return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      background = { light = 'latte', dark = 'mocha' }, -- latte, frappe, macchiato, mocha
      dim_inactive = {
        enabled = false,
        -- Dim inactive splits/windows/buffers.
        -- NOT recommended if you use old palette (a.k.a., mocha).
        shade = 'dark',
        percentage = 0.15,
      },
      show_end_of_buffer = false, -- show the '~' characters after the end of buffers
      term_colors = true,
      compile_path = vim.fn.stdpath 'cache' .. '/catppuccin',
      styles = {
        comments = { 'italic' },
        functions = { 'bold' },
        keywords = { 'italic' },
        operators = { 'bold' },
        conditionals = { 'bold' },
        loops = { 'bold' },
        booleans = { 'bold', 'italic' },
        numbers = {},
        types = {},
        strings = {},
        variables = {},
        properties = {},
      },
      integrations = {
        treesitter = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
          },
          underlines = {
            errors = { 'underline' },
            hints = { 'underline' },
            warnings = { 'underline' },
            information = { 'underline' },
          },
        },
        aerial = true,
        alpha = false,
        barbar = false,
        beacon = false,
        cmp = true,
        coc_nvim = false,
        dap = true,
        dap_ui = true,
        dashboard = false,
        dropbar = { enabled = true, color_mode = true },
        fern = false,
        fidget = true,
        flash = true,
        gitgutter = false,
        gitsigns = true,
        harpoon = false,
        headlines = false,
        hop = true,
        illuminate = true,
        indent_blankline = { enabled = true, colored_indent_levels = false },
        leap = false,
        lightspeed = false,
        lsp_saga = true,
        lsp_trouble = true,
        markdown = true,
        mason = true,
        mini = false,
        navic = { enabled = false },
        neogit = false,
        neotest = false,
        neotree = { enabled = false, show_root = true, transparent_panel = false },
        noice = false,
        notify = true,
        nvimtree = true,
        overseer = false,
        pounce = false,
        rainbow_delimiters = true,
        render_markdown = true,
        sandwich = false,
        semantic_tokens = true,
        symbols_outline = false,
        telekasten = false,
        telescope = { enabled = true, style = 'nvchad' },
        treesitter_context = true,
        ts_rainbow = false,
        vim_sneak = false,
        vimwiki = false,
        which_key = true,
      },
      color_overrides = {},
      -- flavour = 'auto', -- latte, frappe, macchiato, mocha
      -- background = {    -- :h background
      --   light = 'latte',
      --   dark = 'mocha',
      -- },
      -- transparent_background = false, -- disables setting the background color.
      -- show_end_of_buffer = false,     -- shows the '~' characters after the end of buffers
      -- term_colors = false,            -- sets terminal colors (e.g. `g:terminal_color_0`)
      -- dim_inactive = {
      --   enabled = false,              -- dims the background color of inactive window
      --   shade = 'dark',
      --   percentage = 0.15,            -- percentage of the shade to apply to the inactive window
      -- },
      -- no_italic = false,              -- Force no italic
      -- no_bold = false,                -- Force no bold
      -- no_underline = false,           -- Force no underline
      -- styles = {                      -- Handles the styles of general hi groups (see `:h highlight-args`):
      --   comments = { 'italic' },      -- Change the style of comments
      --   conditionals = { 'italic' },
      --   loops = {},
      --   functions = {},
      --   keywords = {},
      --   strings = {},
      --   variables = {},
      --   numbers = {},
      --   booleans = {},
      --   properties = {},
      --   types = {},
      --   operators = {},
      --   -- miscs = {}, -- Uncomment to turn off hard-coded styles
      -- },
      -- color_overrides = {},
      -- custom_highlights = {},
      -- default_integrations = true,
      -- integrations = {
      --   cmp = true,
      --   gitsigns = true,
      --   nvimtree = true,
      --   treesitter = true,
      --   notify = false,
      --   mini = {
      --     enabled = true,
      --     indentscope_color = '',
      --   },
      --   -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
      -- },
    }

    -- setup must be called before loading
    vim.cmd.colorscheme 'catppuccin'
  end,
}
