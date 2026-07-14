-- Shadows the plugin's colors/darkvoid.lua (config dir wins in rtp) to layer
-- C++ readability tweaks on top of the palette configured in plugins/theme.lua:
-- functions carry weight, punctuation/scope noise recedes. Colors themselves
-- are untouched.
require("darkvoid").load()

local hl = vim.api.nvim_set_hl

-- Functions keep their mint, gain weight — call sites anchor the line in C++.
for _, g in ipairs({
    "Function",
    "@function",
    "@function.call",
    "@function.builtin",
    "@function.method",
    "@function.method.call",
    "@lsp.type.function",
    "@lsp.type.method",
}) do
    hl(0, g, { fg = "#5EEEAF", bold = true })
end

-- C++ noise recedes: template/bracket/delimiter soup and std::-style scope
-- prefixes drop to mid-gray so the names they wrap carry the line.
for _, g in ipairs({
    "Delimiter",
    "@punctuation.bracket",
    "@punctuation.delimiter",
    "@namespace",
    "@module",
    "@lsp.type.namespace",
}) do
    hl(0, g, { fg = "#a8a8a8" })
end
