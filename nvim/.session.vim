let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +121 .config/nvim/lua/core/keymaps.lua
badd +1 .config/nvim/lua/core/options.lua
badd +1 .config/nvim/lua/core/snippets.lua
badd +68 .config/nvim/lua/plugins/autocompletion.lua
badd +1 .config/nvim/lua/plugins/bufferline.lua
badd +1 .config/nvim/lua/plugins/comment.lua
badd +1 .config/nvim/lua/plugins/database.lua
badd +10 .config/nvim/lua/plugins/debug.lua
badd +1 .config/nvim/lua/plugins/gitsigns.lua
badd +1 .config/nvim/lua/plugins/indent-blankline.lua
badd +1 .config/nvim/lua/plugins/lazygit.lua
badd +208 .config/nvim/lua/plugins/lsp.lua
badd +1 .config/nvim/lua/plugins/lualine.lua
badd +1 .config/nvim/lua/plugins/misc.lua
badd +1 .config/nvim/lua/plugins/neo-tree.lua
badd +56 .config/nvim/lua/plugins/none-ls.lua
badd +69 .config/nvim/lua/plugins/telescope.lua
badd +28 .config/nvim/lua/plugins/treesitter.lua
badd +34 .config/nvim/lua/plugins/alpha.lua
badd +1 .config/nvim/lua/plugins/venv-selector.lua
badd +52 .config/nvim/init.lua
badd +1 .config/nvim/.stylua.toml
argglobal
%argdel
$argadd ~/.config/nvim
edit .config/nvim/lua/core/keymaps.lua
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 40 + 106) / 212)
exe 'vert 2resize ' . ((&columns * 171 + 106) / 212)
tcd ~/.config/nvim
argglobal
enew
file ~/neo-tree\ filesystem\ \[1]
balt ~/.config/nvim/lua/core/options.lua
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
wincmd w
argglobal
balt ~/.config/nvim/lua/core/options.lua
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 121 - ((101 * winheight(0) + 51) / 102)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 121
normal! 022|
wincmd w
2wincmd w
exe 'vert 1resize ' . ((&columns * 40 + 106) / 212)
exe 'vert 2resize ' . ((&columns * 171 + 106) / 212)
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
