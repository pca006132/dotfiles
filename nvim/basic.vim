" Basic configurations
if &compatible
  set nocompatible
endif

" disable plugins
let g:loaded_matchit           = 1
let g:loaded_logiPat           = 1
let g:loaded_rrhelper          = 1
let g:loaded_tarPlugin         = 1
let g:loaded_gzip              = 1
let g:loaded_zipPlugin         = 1
let g:loaded_2html_plugin      = 1
let g:loaded_shada_plugin      = 1
let g:loaded_spellfile_plugin  = 1
let g:loaded_netrw             = 1
let g:loaded_netrwPlugin       = 1
let g:loaded_tutor_mode_plugin = 1
let g:loaded_remote_plugins    = 1

set guifont="DejaVu Sans Mono":h11
filetype on
filetype plugin on
filetype indent on
syntax enable
set nobackup
set noswapfile
set autoread
set autowrite
set hidden
set wildmenu wildmode=full
set splitbelow
set splitright
" set bsdir=buffer
if has('vim_starting')
    set encoding=UTF-8
    scriptencoding UTF-8
endif
set autoindent shiftwidth=2
set backspace=indent,eol,start
set cindent shiftwidth=2
set shiftwidth=2
set cmdheight=2         " Height of the command line
set completefunc=emoji#complete
set completeopt=longest,menu
set cpoptions-=m        " showmatch will wait 0.5s or until a char is typed
set expandtab
set history=2000
set hlsearch            " Highlight search results
set ignorecase          " Search ignoring case
set incsearch           " Incremental search
set infercase           " Adjust case in insert completion mode
set laststatus=2
set lazyredraw
set lbr
set list
set listchars=tab:»·,nbsp:+,trail:·,extends:→,precedes:←
set magic
set matchtime=1         " Tenths of a second to show the matching paren
set mouse=a
set noerrorbells
set novisualbell
set number              "hybrid line number
set relativenumber
set ruler
set sessionoptions+=globals
set shortmess=aFc
set showmatch           " Jump to matching bracket
set showtabline=2
set signcolumn=yes
set smartcase           " Keep case when searching with *
set smarttab
set so=5
set statusline=-
set t_Co=256
set tabstop=4
set textwidth=80
set timeout ttimeout
set timeoutlen=500
set ttimeoutlen=10
set undodir=~/.tmp/undo
set undofile
set updatetime=100
set virtualedit=onemore
set wildignore+=*.so,*~,*/.git/*,*/.svn/*,*/.DS_Store,*/tmp/*
set wrap
set wrapscan        " Searches wrap around the end of the file
if has('conceal')
  set conceallevel=2
endif

" ========================= Utilities ======================
" Reformat lines (getting the spacing correct) {{{
fun! TeX_fmt(start, end)
    silent execute a:start.','.a:end.'s/[,.!?]\zs /\r/g'
endfun


" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
if has('folding')
  set foldenable
  set foldmethod=indent
  set foldlevelstart=99
  set foldtext=FoldText()
endif
" Improved Vim fold-text
function! FoldText()
  " Get first non-blank line
  let fs = v:foldstart
  while getline(fs) =~? '^\s*$' | let fs = nextnonblank(fs + 1)
  endwhile
  if fs > v:foldend
    let line = getline(v:foldstart)
  else
    let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
  endif
  let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
  let foldSize = 1 + v:foldend - v:foldstart
  let foldSizeStr = ' ' . foldSize . ' lines '
  let foldLevelStr = repeat('+--', v:foldlevel)
  let lineCount = line('$')
  let foldPercentage = printf('[%.1f', (foldSize*1.0)/lineCount*100) . '%] '
  let expansionString = repeat('.', w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
  return line . expansionString . foldSizeStr . foldPercentage . foldLevelStr
endfunction
if has("autocmd")
    autocmd BufWritePre *.js,*.py,*.sh,*.ts,*.mk,*.rs,*.c,*.cpp :call CleanExtraSpaces()
    autocmd FileType make setlocal noexpandtab
    autocmd FileType tex setlocal formatexpr=TeX_fmt(v:lnum,v:lnum+v:count-1)
    autocmd FileType tex setlocal formatoptions+=b
    autocmd FileType tex setlocal textwidth=0
    autocmd FileType clojure,scheme,lisp,racket,hy,fennel,janet,carp,wast,yuck,dune let b:loaded_delimitMate=1
endif
" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")
    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif
    if bufnr("%") == l:currentBufNum
        new
    endif
    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction
