-- 0. Setup all my non-plugins configs,1c1c1c"
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

-- At first, this list will be empty. We will add plugins back one by one.
require('lazy').setup({
	require 'plugins.theme',         -- Theme
	require 'plugins.lualine',       -- Status Bar at the bottom
	require 'plugins.misc',          -- Autopairs, comments, indent-blankline...
	require 'plugins.gitsigns',      -- Git Signs when changing from latest git repo where numbers are
	require 'plugins.comment',       -- Plugin to comment and uncomment lines
	require 'plugins.mini-files',    -- File Explorer
	-- require 'plugins.mini-indentscope', -- Dynamic indenting
	require 'plugins.indent-blankline', -- Indentation guides to NeoVim
	require 'plugins.alpha',         -- Cool Logo
	require 'plugins.smear',         -- Cursor movement more visible
	require 'plugins.flash',         -- Navigate your code with search labels, enhanced character motions
	require 'plugins.treesitter',    -- Turn source code into a detailed, structured tree.
	require 'plugins.noice',         -- Plugin that completely replaces the UI for messages, cmdline and the popupmenu
	require 'plugins.lsp',           -- Language Server Protocol
	require 'plugins.conform',       -- Lightweight yet powerful formatter plugin for Neovim
	require 'plugins.snacks',        -- Fuzzy Finder
	require 'plugins.cmp',           -- Autocomplete
	require 'plugins.leetcode',      -- Leetcode in NeoVim plugin
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
