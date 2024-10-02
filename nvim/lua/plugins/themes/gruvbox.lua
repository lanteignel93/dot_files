return {
  'sainnhe/gruvbox-material',
  lazy = false,
  config = function()
    -- Optionally configure and load the colorscheme
    -- directly inside the plugin declaration.
    vim.g.gruvbox_material_enable_italic = true
    --background option can be hard, medium, soft
    vim.g.gruvbox_material_background = 'medium'
    vim.g.gruvbox_material_enable_bold = 1
    vim.g.gruvbox_material_transparent_background = 1
    vim.g.gruvbox_material_ui_contrast = 'high'
    --foreground option can be material, mix, original
    vim.g.gruvbox_material_foreground = 'mix'
    vim.cmd.colorscheme 'gruvbox-material'
  end,
}
