-- lua/plugins/mini-surround.lua (or add to your existing mini.nvim spec)
return {
  "echasnovski/mini.nvim", -- This is the main plugin that contains mini.surround
  -- `version = false` -- Uncomment if you want to use the latest commit from the main branch
  -- `version = "*"` -- Or use this to track the latest stable tag

  -- No specific event is strictly necessary for mini.surround to load,
  -- as its setup will make its mappings available.
  -- You could use `event = "VeryLazy"` if you prefer.

  -- The `opts` table is passed to the `config` function by LazyVim.
  -- It's a clean way to specify options that will be used in `require('mini.surround').setup(opts)`.
  opts = {
    -- Options for mini.surround
    -- Refer to `:help MiniSurround.config` for all available options

    -- Add/delete/replace surroundings with default mappings:
    -- sa - Add surrounding (Normal and Visual modes)
    -- sd - Delete surrounding
    -- sr - Replace surrounding
    -- sf - Find right surrounding
    -- sF - Find left surrounding
    -- sh - Highlight surrounding
    -- sn - Select 'inner' textobject (e.g., `sni(` selects content inside `()`)
    -- sN - Select 'outer' textobject (e.g., `sNa` selects `<a>...</a>` including tags)
    --
    -- Note: LazyVim by default remaps these to `gs` prefixed keys (gsa, gsd, etc.)
    -- to avoid conflicts with its own `s` keymap for Flash.nvim.
    -- If you want the original `s` prefix, you'll need to manage keymap conflicts
    -- or disable/change LazyVim's default `s` mapping.
    -- The configuration below will respect LazyVim's `gs` prefix if you're using
    -- the LazyVim starter. If you have a custom setup, adjust mappings as needed.

    -- Example: Customizing mappings (if you don't like the `gs` prefix from LazyVim default)
    -- This is how you would override if you are NOT using LazyVim's extra for mini-surround
    -- which already handles the `gs` prefix. If you ARE using LazyVim's extra,
    -- you might adjust the mappings it sets or stick to its defaults.
    -- mappings = {
    --   add = "sa",
    --   delete = "sd",
    --   find = "sf",
    --   find_left = "sF",
    --   highlight = "sh",
    --   replace = "sr",
    --   update_n_lines = "sn", -- This is actually for MiniSurround.config.n_lines, not textobject
    -- },

    custom_surroundings = {
      -- Define your own custom surroundings.
      -- Example: Markdown bold `**text**` (if defaults aren't quite right or for learning)
      -- ['*'] = { output = { left = "**", right = "**" } },
      -- Example: Environment for LaTeX
      -- e = {
      --   input = '\\\\begin{(%w-)}.-%s*\\\\end{(%w-)}',
      --   output = function()
      --     local env_name = vim.fn.input('Environment name: ')
      --     if env_name == '' then return end
      --     return { left = '\\begin{' .. env_name .. '}\n\t', right = '\n\\end{' .. env_name .. '}' }
      --   end,
      -- },
    },

    -- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
    highlight_duration = 500,

    -- Number of columns for N-th surrounding to find ('MiniSurround.findNth')
    n_columns = 80,

    -- Side to search for N-th surrounding: 'left', 'right', or 'both'
    -- Other options: 'cover_or_next', 'cover_or_prev', 'cover_or_nearest'
    search_method = 'cover_or_next', -- A common and useful default

    -- Whether to disable showing non-error feedback (e.g., "Added surrounding...")
    silent = false,
  },

  config = function(_, opts)
    -- The `opts` argument here is the table from the `opts` key above.
    require("mini.surround").setup(opts)

    -- If you are using the default LazyVim distribution, it might already
    -- configure mini.surround with `gs` prefixed keymaps via its "extras".
    -- If you want to ensure your own `s` prefixed mappings (and you've handled
    -- potential conflicts with LazyVim's default `s` mapping for flash.nvim),
    -- you would define them here or directly in the `opts.mappings` table above.

    -- Example: If you want to force `s` prefixed mappings and know you've
    --          disabled LazyVim's `s` mapping for flash.nvim or prefer `s` for surround:
    -- local surround_maps = require('mini.surround').config.mappings
    -- vim.keymap.set({ "n", "x" }, "sa", surround_maps.add, { desc = "Add Surrounding" })
    -- vim.keymap.set("n", "sd", surround_maps.delete, { desc = "Delete Surrounding" })
    -- vim.keymap.set("n", "sr", surround_maps.replace, { desc = "Replace Surrounding" })
    -- vim.keymap.set("n", "sf", surround_maps.find, { desc = "Find Right Surrounding" })
    -- vim.keymap.set("n", "sF", surround_maps.find_left, { desc = "Find Left Surrounding" })
    -- vim.keymap.set("n", "sh", surround_maps.highlight, { desc = "Highlight Surrounding" })
    -- vim.keymap.set("n", "sn", surround_maps.update_n_lines, { desc = "Update n_lines" }) -- Note: this mapping has a specific purpose
  end,
}
