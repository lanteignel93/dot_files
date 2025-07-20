-- In your lualine.lua or wherever you configure the plugin
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- 1. DEFINE YOUR DARKVOID THEME COLORS
    local colors = {
      fg = '#c0c0c0', -- main foreground
      bg = '#1c1c1c', -- main background
      lime = '#bdfe58', -- for normal mode (from your 'kw' color)
      sea_green = '#5EEEAF', -- for command mode (from your 'func' color)
      lavender = '#E5CCFF', -- for visual mode (from your 'string' color)
      light_blue = '#99CCFF', -- for insert mode (from your 'type' color)
      red = '#dea6a0', -- for replace mode (from your 'error' color)
      info_blue = '#7fa1c3', -- for terminal mode (from your 'info' color)
      dark_gray = '#303030', -- for section 'b' background (from your 'visual' color)
      mid_gray = '#404040', -- for section 'c' background (from your 'line_nr' color)
      light_gray = '#585858', -- for inactive text (from your 'comment' color)
    }

    -- 2. CREATE THE LUALINE THEME TABLE
    local darkvoid_theme = {
      normal = {
        a = { fg = colors.bg, bg = colors.lime, gui = 'bold' },
        b = { fg = colors.fg, bg = colors.dark_gray },
        c = { fg = colors.fg, bg = colors.mid_gray },
      },
      insert = { a = { fg = colors.bg, bg = colors.light_blue, gui = 'bold' } },
      visual = { a = { fg = colors.bg, bg = colors.lavender, gui = 'bold' } },
      command = { a = { fg = colors.bg, bg = colors.sea_green, gui = 'bold' } },
      replace = { a = { fg = colors.bg, bg = colors.red, gui = 'bold' } },
      terminal = { a = { fg = colors.bg, bg = colors.info_blue, gui = 'bold' } },
      inactive = {
        a = { fg = colors.light_gray, bg = colors.bg, gui = 'bold' },
        b = { fg = colors.light_gray, bg = colors.bg },
        c = { fg = colors.light_gray, bg = colors.dark_gray },
      },
    }

    -- 3. ADD YOUR NEW THEME TO THE LIST OF AVAILABLE THEMES
    local themes = {
      -- your original themes
      onedark = 'onedark', -- Kept for reference, but can be removed
      nord = 'nord',
      gruvbox = 'gruvbox',
      catppuccin = 'catppuccin',
      -- Your new theme!
      darkvoid = darkvoid_theme,
    }

    -- Set 'darkvoid' as the default if NVIM_THEME is not set
    local env_var_nvim_theme = os.getenv 'NVIM_THEME' or 'darkvoid'

    -- (Your other lualine component settings remain the same)
    local mode = {
      'mode',
      fmt = function(str)
        return ' ' .. str
      end,
    }

    local filename = {
      'filename',
      file_status = true,
      path = 0,
    }

    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end

    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn' },
      symbols = { error = ' ', warn = ' ' },
      colored = false,
      cond = hide_in_width,
    }

    local diff = {
      'diff',
      colored = false,
      symbols = { added = ' ', modified = ' ', removed = ' ' },
      cond = hide_in_width,
    }

    -- 4. SETUP LUALINE
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = themes[env_var_nvim_theme], -- This will now correctly load your darkvoid theme
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = { statusline = { 'alpha', 'neo-tree' } },
        always_divide_middle = true,
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { 'branch' },
        lualine_c = { filename },
        lualine_x = { diagnostics, diff, { 'encoding', cond = hide_in_width }, { 'filetype', cond = hide_in_width } },
        lualine_y = { 'location' },
        lualine_z = { 'progress' },
      },
      inactive_sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { { 'location', padding = 0 } },
      },
      tabline = {
        lualine_a = { 'buffers' },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'tabs' },
      },
      extensions = { 'fugitive' },
    }
  end,
}
