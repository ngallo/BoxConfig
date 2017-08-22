set guioptions-=T

set mouse=a													" Enable basic mouse behavior such as resizing buffers.

nmap <A-{> :tabprev<CR>
nmap <A-}> :tabnext<CR>
nmap <A-n> :tabnew<CR>

" put wd in the window title
set titlestring=%{fnamemodify(getcwd(),':~')}

if has("gui_win32")
    set guifont=Consolas:h11:cANSI
endif

" Source local cutomizations
if filereadable(expand("~/.gvimrc.local"))
  source ~/.gvimrc.local
endif
