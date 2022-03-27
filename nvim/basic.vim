" Basic configurations
if &compatible
  set nocompatible
endif
set guifont=monospace:h11
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
set bsdir=buffer
if has('vim_starting')
    set encoding=UTF-8
    scriptencoding UTF-8
endif
set autoindent shiftwidth=4
set backspace=indent,eol,start
set cindent shiftwidth=4
set cmdheight=2         " Height of the command line
set completefunc=emoji#complete
set completeopt=longest,menu
set cpoptions-=m        " showmatch will wait 0.5s or until a char is typed
set expandtab
set grepprg=rg\ --vimgrep\ $*
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
