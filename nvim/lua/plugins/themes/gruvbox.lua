return {
  'sainnhe/gruvbox-material',
  lazy = false,
  config = function()
    -- Optionally configure and load the colorscheme
    -- directly inside the plugin declaration.
    vim.g.gruvbox_material_enable_italic = true
    --background option can be hard, medium, soft
    vim.g.gruvbox_material_background = 'soft'
    --0 or 1
    vim.g.gruvbox_material_enable_bold = 1
    --0 or 1 or 2
    vim.g.gruvbox_material_transparent_background = 2
    --low or high
    vim.g.gruvbox_material_ui_contrast = 'high'
    --foreground option can be material, mix, original
    vim.g.gruvbox_material_foreground = 'mix'
    -- default is grey
    vim.g.gruvbox_material_menu_selection_background = "blue"
    -- 0 or 1 
    vim.g.gruvbox_material_diagnostic_text_highlight = 1
    vim.cmd.colorscheme 'gruvbox-material'
  end,
}
