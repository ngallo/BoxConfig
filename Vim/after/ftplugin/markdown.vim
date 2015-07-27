
setlocal tw=78                  " text width 78 chars
setlocal cc=81                  " display red line at char 81

" treat numbered lists (1. 1.2, a.), - and * and [1] footnotes as lists
" 1. blahj
" 1.2 blah
" a. blah
" * blah
" - blah
" [^1] blah
" when reformatting
let &formatlistpat='^\s*\(\d\+\.\)\+\s\+\|^\s*[-*+]\s\+\|^\s*\[\d\+\]\s\+\|^\[^.*\]:\s\+\|^\s*\(\l\.\)\s\+'
setlocal autoindent
setlocal formatoptions=tnr     " hard wrap and format while typing

"
" Apply a left margin when editing markdown
"
setlocal foldcolumn=1
:hi! link FoldColumn Normal


