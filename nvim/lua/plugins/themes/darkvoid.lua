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
				fg = "#c0c0c0",
				bg = "#1c1c1c",
				cursor = "#bdfe58",
				line_nr = "#404040",
				visual = "#303030",
				comment = "#585858",
				-- string = "#f1f1f1",
				string = "#E5CCFF",
				-- func = "#e1e1e1",
				func = "#5EEEAF",
				-- kw = "#f1f1f1",
				kw = "#bdfe58",
				-- identifier = "#E5CCFF",
				-- identifier = "#b1b1b1",
				identifier = "#f1f1f1",
				type = "#99CCFF",
				type_builtin = "#99CCFF",
				search_highlight = "#5EEEAF",
				operator = "#5EEEAF",
				bracket = "#e6e6e6",
				preprocessor = "#4b8902",
				bool = "#99CCFF",
				constant = "#b2d8d8",
				-- constant = "#bdfe58",

				-- enable or disable specific plugin highlights
				plugins = {
					gitsigns = true,
					nvim_cmp = true,
					treesitter = true,
					nvimtree = true,
					telescope = true,
					lualine = true,
					bufferline = true,
					oil = true,
					whichkey = true,
					nvim_notify = false,
				},

				-- gitsigns colors
				added = "#baffc9",
				changed = "#ffffba",
				removed = "#ffb3ba",

				-- Pmenu colors
				pmenu_bg = "#1c1c1c",
				pmenu_sel_bg = "#1bfd9c",
				pmenu_fg = "#c0c0c0",

				-- EndOfBuffer color
				eob = "#3c3c3c",

				-- Telescope specific colors
				border = "#585858",
				title = "#bdfe58",

				-- bufferline specific colors
				bufferline_selection = "#1bfd9c",

				-- LSP diagnostics colors
				error = "#dea6a0",
				warning = "#d6efd8",
				hint = "#bedc74",
				info = "#7fa1c3",
			},
		})
		-- setup must be called before loading
		vim.cmd("colorscheme darkvoid")
	end,
},
	{
    "rcarriga/nvim-notify",
    event = "VeryLazy", -- Or on a specific event after startup
    config = function()
      -- It's often better to let notify pick up the theme's highlight
      -- But if overriding, ensure the theme's NotifyBackground is set first
      -- Or explicitly define NotifyBackground before this setup (see next point)
      require("notify").setup({
        background_colour = "#000000",
        -- Consider if you really need to force #000000
        -- if your theme should provide NotifyBackground
      })
    end,
  },
}
