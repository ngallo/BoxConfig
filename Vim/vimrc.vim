
"
" Set up vundle
"
set nocompatible
filetype off

" Set rtp based on windows, posix or cygwin  (shellcmdflag for cygwin detection)
let win_shell = (has('win32') || has('win64')) && &shellcmdflag =~ '/'
let vimDir = win_shell ? '$HOME/vimfiles' : '$HOME/.vim'
let &runtimepath .= ',' . expand(vimDir . '/vundle')

call vundle#begin(expand(vimDir . '/bundle'))
    Plugin 'mileszs/ack.vim'
    Plugin 'applescript.vim'
    Plugin 'bundler'
    Plugin 'commentary.vim'
    Plugin 'ctrlp.vim'
    Plugin 'vim-scripts/DeleteTrailingWhitespace'
    Plugin 'endwise.vim'
    Plugin 'greplace.vim'
"    Plugin 'Markdown'
    Plugin 'cakebaker/scss-syntax.vim'
    Plugin 'scrooloose/syntastic'
    Plugin 'jtratner/vim-flavored-markdown'
    Plugin 'airblade/vim-gitgutter'
    " no tagbar
    Plugin 'pangloss/vim-javascript'
    Plugin 'junegunn/vim-easy-align'
    Plugin 'vim-pandoc/vim-pandoc-syntax'
    " One to try:
    " Plugin 'vim-addon-ruby-debug-ide'
call vundle#end()            " required
filetype plugin indent on                                    " filetypes on after packages loaded


syntax enable                                                " enable syntax highlighting
set autoindent                                               " auto indent lines
set autoread                                                 " reload files when changed on disk, i.e. via `git checkout`
set backspace=2                                              " Fix broken backspace in some setups
set backupcopy=auto                                          " dont break links
set directory-=.                                             " don't store swapfiles in the current directory
set directory+=$HOME/tmp                                     " store swapfiles in users tmp
set encoding=utf-8
set hlsearch                                                 " highlight searchs
set incsearch                                                " search as you type
set laststatus=2                                             " always show statusline
set list                                                     " show trailing whitespace
set listchars=tab:▸\ ,trail:▫
set ruler                                                    " show where you are
set scrolloff=3                                              " show context above/below cursorline
set shiftwidth=4                                             " normal mode indentation commands use 4 spaces
set showcmd
set ignorecase
set smartcase                                                " case-sensitive search if any caps
set tabstop=4                                                " actual tabs occupy 4 characters
set expandtab                                                " expand tabs by default
set wildignore=log/**,node_modules/**,target/**,tmp/**,*.rbc
set wildmenu                                                 " show a navigable menu for tab completion
set wildmode=longest,list,full
set switchbuf=usetab,newtab                                 " have quickfix commands use tabs
set ve=block                                                " virtual edit when block select  (^V)
set diffopt=filler,vertical,context:100                     " virtical split in diff, only fold if 100 lines match

"
" keyboard shortcuts
"
let mapleader = ','
nmap <leader>b :CtrlPBuffer<CR>
nmap <leader>d :NERDTreeToggle<CR>
nmap <leader>f :NERDTreeFind<CR>
nmap <leader>q :q<CR>
nmap <leader>w :w<CR>
nmap <leader>t :CtrlPCurWD<CR>
nmap <leader>T :CtrlP<CR>
nmap <leader>] :TagbarToggle<CR>
nmap <leader><space> :DeleteTrailingWhitespace<CR>
nmap <leader>g :GitGutterToggle<CR>
map <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
map <leader>v :tabnew $HOME/.vimrc<CR>
nmap <silent> <leader>z :set spell!<CR>
vmap <leader>e :call ExtractVariable()<CR>
map <leader>o :wincmd o<CR>
"
"Easy align
"
 "interactive align of text object or motion
vmap <Enter> <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

"
" Ctrlp settings
"
let g:ctrlp_match_window = 'order:ttb,max:20'
let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("e")': [],
  \ 'AcceptSelection("t")': ['<cr>', '<c-m>'],
  \ }

"
" Gitgutter settings
"
let g:gitgutter_enabled = 0
let g:gitgutter_diff_args = '-w'

"
"  AG setup
"
if executable('ag')
  let g:ackprg = 'ag --nogroup --column --ignore *min.js'
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor
  let g:gitgutter_escape_grep = 1
  " Use ag if not on windows  (some problem with AG Mar2015)
  let g:ctrlp_user_command = 'ag -l --nocolor -g "" %s '
    nmap <leader>a :Ack<Space>
else   " no ag so map it to a vimgrep  (slow)
    nmap <leader>a :RvGrep
endif

" do something similar to ack when ack is not installed on windows
function! s:RVimGrep(text)
    exe 'lvimgrep /' . a:text. "/g ./**/*.*"
endfunction
com! -nargs=1 RvGrep call s:RVimGrep(<f-args>)

"
" filetypes
"
autocmd BufRead,BufNewFile *.fdoc set filetype=yaml                " fdoc is yaml
autocmd BufRead,BufNewFile *.build set filetype=xml                " msbuild is xml
autocmd BufRead,BufNewFile *.plist set filetype=xml                " plist is xml
autocmd BufRead,BufNewFile *.build set filetype=xml                " msbuild is xml
autocmd BufRead,BufNewFile *.targets set filetype=xml              " msbuild is xml
autocmd VimResized * :wincmd =                                     " automatically rebalance windows on vim resize

"
" Markdown / pandoc
"
augroup markdown
    au!
    au BufNewFile,BufRead README,*.md setlocal filetype=markdown.pandoc
augroup END
" Do not use conceal
let g:pandoc#syntax#conceal#use = 0

"
" gui settings
"
if (&t_Co == 256 || has('gui_running'))
  if ($TERM_PROGRAM == 'iTerm.app')
    colorscheme solarized
  else
    colorscheme desert
    highlight Signcolumn guibg=DarkBlue
  endif
endif

"
" show differene between file buffer and the saved file on disk
"
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

function! s:DiffSvnBase()
  let filetype=&ft
  diffthis
  vnew | exe "%!svn cat " . expand("#:p")
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffBase call s:DiffSvnBase()

function! s:DiffSvnHead()
  let filetype=&ft
  diffthis
  vnew | exe "%!svn cat -r HEAD " . expand("#:p")
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffHead call s:DiffSvnHead()

function! ExtractVariable() range
  let name = input("Name of new variable:")
  " go to previous visual selection
  exe "normal! gv"
  "put selection into "r and replace with name
  exe "normal! \"rc" . name
  " line above create the variable
  exe "normal! O" . name . " = "
  " paste "r into definition
  normal! "rp
endfunction

function! TerminalTabHere()
	exe "silent !ttab " . expand("%:p") . ""
	exe "redraw!"
endfunction
com! Ttab call TerminalTabHere()



" Show syntax highlighting groups for word under cursor
nmap <leader>z :call <SID>SynStack()<CR>

function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc


" Source local cutomizations
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

command! -range=% RunRuby call s:RunToScratch("ruby", getline(<line1>,<line2>), 0)
command! -range=% RunSql call s:RunToScratch( "psql -d delta -P footer=off --set ON_ERROR_STOP=1 ", getline(<line1>,<line2>), 1)
command! -range=% RunShell call s:RunToScratch( "bash", getline(<line1>,<line2>), 1)

function! s:RunBufferShow(resname)
    let l:reswin = bufwinnr(a:resname)
    if l:reswin > -1                      " window lready open
        exe "sbuffer " . a:resname
    else                                " Open a new split and set it up.
        exe "belowright split " . a:resname
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal bufhidden=hide
        setlocal ft=sql
        hi CmdErrors guifg=red
    endif
endfunction

function! s:RunToScratch(cmd, query, include_input)
    " execute the command passing script to stdin
    let l:results = system(a:cmd, join(a:query, "\n" . "\n"))
    " open a split for the l:results if not already open
    let l:resname = '__Output_' . bufnr('%')
    call s:RunBufferShow(l:resname)
    " append the query to the buffer and scroll it to the middle of the screen
    normal! G
    if a:include_input && v:shell_error == 0
        call append(line('$'), a:query)
        call append(line('$'), "")
    endif
    " append the l:results to the buffer and highlight errors
    call append(line('$'), split(l:results, '\v\n'))
    match CmdErrors /^ERROR:.*$/
    normal! G
    " go back to the original window
    exe "wincmd p"
endfunction

" dbext
let g:dbext_default_profile_usual ='type=PGSQL:user=:passwd=:host=localhost:dbname=delta:extra=-P footer=off'
let g:dbext_default_PGSQL_extra   = '-P footer=off --set ON_ERROR_STOP=1'
let g:dbext_default_PGSQL_pgpass             = expand('$HOME/.pgpass')
let g:dbext_default_profile = 'usual'

