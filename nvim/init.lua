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
	{ import = 'plugins.theme' },
	{ import = 'plugins.lualine' },
	{ import = 'plugins.misc' },
	{ import = 'plugins.gitsigns' },
	{ import = 'plugins.comment' },
	{ import = 'plugins.mini-files' },
	{ import = 'plugins.indent-blankline' },
	{ import = 'plugins.alpha' },
	{ import = 'plugins.smear' },
	{ import = 'plugins.flash' },
	{ import = 'plugins.treesitter' },
	{ import = 'plugins.noice' },
	{ import = 'plugins.lsp' }, -- This will now load safely!
	{ import = 'plugins.conform' },
	{ import = 'plugins.snacks' },
	{ import = 'plugins.cmp' },
	{ import = 'plugins.leetcode' },
	{ import = 'plugins.markview' },
	{ import = 'plugins.bullet' },
	{ import = 'plugins.lazygit' },
	{ import = 'plugins.dap' },
	{ import = 'plugins.scooter' },
	{ import = 'plugins.obsidian' },
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
