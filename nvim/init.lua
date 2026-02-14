require 'core.keymaps'  -- Load general keymaps
require 'core.options'  -- Load general options
require 'core.snippets' -- Custom code snippets

-- 1. SET UP LAZY.NVIM
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable', -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	{ import = 'plugins.theme' },         -- Colorscheme configuration
	{ import = 'plugins.lualine' },       -- The status line bar at the bottom of the window
	{ import = 'plugins.misc' },          -- Collection of small, uncategorized utilities
	{ import = 'plugins.gitsigns' },      -- Git indicators (added/modified lines) in the sidebar gutter
	{ import = 'plugins.comment' },       -- Easy commenting keymaps (usually 'gc' to toggle)
	{ import = 'plugins.mini-files' },    -- A minimal, fast file explorer/tree
	{ import = 'plugins.indent-blankline' }, -- Vertical lines guiding indentation levels
	{ import = 'plugins.alpha' },         -- The startup dashboard/greeter screen
	{ import = 'plugins.flash' },         -- Fast navigation allowing you to jump to specific words
	{ import = 'plugins.treesitter' },    -- Advanced syntax highlighting and code parsing
	{ import = 'plugins.noice' },         -- Modernizes the UI for messages, command line, and popups
	{ import = 'plugins.lsp' },           -- Language Server Protocol (Diagnostics, Go-to-Definition)
	{ import = 'plugins.conform' },       -- Code formatter (auto-formats on save)
	{ import = 'plugins.snacks' },        -- A bundle of "Quality of Life" tools (scratchpads, terminal, etc.)
	{ import = 'plugins.cmp' },           -- The autocompletion dropdown menu engine
	{ import = 'plugins.leetcode' },      -- Interface for solving LeetCode problems inside Neovim
	{ import = 'plugins.markview' },      -- Renders Markdown (headings, tables) nicely directly in the buffer
	{ import = 'plugins.bullet' },        -- Auto-formatting for bulleted lists (useful for notes)
	{ import = 'plugins.lazygit' },       -- Integration for the LazyGit terminal interface
	{ import = 'plugins.dap' },           -- Debug Adapter Protocol (for debugging code execution)
	{ import = 'plugins.scooter' },       -- Your new "find and replace" TUI integration
	{ import = 'plugins.obsidian' },      -- Integration for Obsidian vaults and daily notes
}, {
	ui = {
		-- If you have a Nerd Font, set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
		border = 'rounded',
		icons = vim.g.have_nerd_font and {} or {
			cmd = '⌘',
			config = '🛠',
			event = '📅',
			ft = '📂',
			init = '⚙',
			keys = '🗝',
			plugin = '🔌',
			runtime = '💻',
			require = '🌙',
			source = '📄',
			start = '🚀',
			task = '📌',
			lazy = '💤 ',
		},
	},
}
)

-- Function to check if a file exists
local function file_exists(file)
	local f = io.open(file, 'r')
	if f then
		f:close()
		return true
	else
		return false
	end
end

-- Path to the session file
local session_file = '.session.vim'

-- Check if the session file exists in the current directory
if file_exists(session_file) then
	-- Source the session file
	vim.cmd('source ' .. session_file)
end
