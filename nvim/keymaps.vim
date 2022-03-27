let mapleader = " "
nmap ; :
set backspace=eol,start,indent
set whichwrap+=<,>,h,l
" copy to/from clipboard
map <Leader>y "+y
map <Leader>p "+p
map <Leader>P "+P
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"
    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")
    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif
    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>
" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>
" Indent multiple times in visual mode
vnoremap > >gv
vnoremap < <gv
" Move on visual line instead of logical lines
noremap j gj
noremap k gk
" Move a line of text using ALT+[jk] or Command+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z
" improved keyboard navigation
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
" go to next buffer
nnoremap <silent> <M-l> :bn<CR>
" go to previous buffer
nnoremap <silent> <M-h> :bp<CR>
" close buffer
nnoremap <silent> <leader>bd :Bclose<CR>
" kill buffer
nnoremap <silent> <leader>bk :bd!<CR>
" disable middle mouse click paste
map <MiddleMouse> <Nop>
imap <MiddleMouse> <Nop>
map <2-MiddleMouse> <Nop>
imap <2-MiddleMouse> <Nop>
map <3-MiddleMouse> <Nop>
imap <3-MiddleMouse> <Nop>
map <4-MiddleMouse> <Nop>
imap <4-MiddleMouse> <Nop>

