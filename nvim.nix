{ pkgs , pkgs-unstable }:
pkgs-unstable.neovim.override
  {
    configure = {
      packages.myVimPackage = with pkgs-unstable.vimPlugins; {
        start = [
          plenary-nvim
          vim-gitgutter
          vim-commentary
          vim-surround
          vim-dispatch
          lightline-vim
          vim-fugitive
          vim-polyglot
          vimtex
          vim-tmux-navigator
          molokai
          codi-vim
          vim-startify
          nerdtree
          nerdtree-git-plugin
          neoterm
          lightline-bufferline
          delimitMate
          telescope-nvim
          indent-blankline-nvim
          lightspeed-nvim
          pkgs.vimPlugins.nvim-treesitter
          pkgs.vimPlugins.nvim-treesitter-textobjects
          pkgs.vimPlugins.nvim-treesitter-context
          nvim-dap
          nvim-dap-ui
          zen-mode-nvim
          neoscroll-nvim
          twilight-nvim
          copilot-vim
          # coc plugins
          coc-nvim
          coc-metals
          coc-java
          coc-json
          coc-pyright
          coc-tsserver
          coc-rust-analyzer
          coc-vimtex
          coc-html
        ];
        opt = [
          vim-latex-live-preview
        ];
      };
      customRC = ''
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
        set t_Co=256
        set laststatus=2
        set statusline=-
        set showtabline=2
        set history=2000
        set number              "hybrid line number
        set relativenumber
        set timeout ttimeout
        set cmdheight=2         " Height of the command line
        set timeoutlen=500
        set ttimeoutlen=10
        set updatetime=100
        set undofile
        set undodir=~/.tmp/undo
        set backspace=2
        set backspace=indent,eol,start
        set tabstop=4
        set cindent shiftwidth=4
        set autoindent shiftwidth=4
        set expandtab
        set smarttab
        set shortmess=aFc
        set signcolumn=yes
        set completefunc=emoji#complete
        set completeopt =longest,menu
        set completeopt-=preview
        set list
        set listchars=tab:»·,nbsp:+,trail:·,extends:→,precedes:←
        set virtualedit=onemore
        set so=5
        set ruler
        set wrap
        set sessionoptions+=globals
        set ignorecase      " Search ignoring case
        set smartcase       " Keep case when searching with *
        set infercase       " Adjust case in insert completion mode
        set incsearch       " Incremental search
        set hlsearch        " Highlight search results
        set wrapscan        " Searches wrap around the end of the file
        set showmatch       " Jump to matching bracket
        set matchtime=1     " Tenths of a second to show the matching paren
        set cpoptions-=m    " showmatch will wait 0.5s or until a char is typed
        set grepprg=rg\ --vimgrep\ $*
        set wildignore+=*.so,*~,*/.git/*,*/.svn/*,*/.DS_Store,*/tmp/*
        set lazyredraw
        set magic
        set noerrorbells
        set novisualbell
        set lbr
        set textwidth=80
        set mouse=a
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
        " See: http://www.gregsexton.org/2011/03/improving-the-text-displayed-in-a-fold/
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
            autocmd BufWritePre *.txt,*.js,*.py,*.md,*.sh,*.ts,*.mk,*.rs,*.c,*.cpp :call CleanExtraSpaces()
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
        " ====================== Key Maps ======================
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
        vnoremap <silent> * :<C-u>call VisualSelection(\'\', \'\')<CR>/<C-R>=@/<CR><CR>
        vnoremap <silent> # :<C-u>call VisualSelection(\'\', \'\')<CR>?<C-R>=@/<CR><CR>
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
        " ======================================================
        " ==================== Color scheme ====================
        " ======================================================
        let g:molokai_original = 0
        colo molokai
        hi MatchParen      guifg=254 guifg=208 gui=bold
        highlight EndOfBuffer ctermfg=bg guifg=bg
        hi Conceal ctermbg=233
        hi Comment ctermfg=gray
        " ======================================================
        " ====================== Gitgutter =====================
        " ======================================================
        set updatetime=250
        highlight SignColumn guibg=bg
        highlight SignColumn ctermbg=bg
        " ======================================================
        " ================== Lightline config ==================
        " ======================================================
        let g:lightline = {
          \ 'active': {
          \   'left': [ [ 'mode', 'paste' ],
          \             [ 'gitbranch', 'cocstatus', 'readonly', 'filename', 'modified' ] ]
          \ },
          \ 'component_function': {
          \   'cocstatus': 'coc#status',
          \   'gitbranch': 'fugitive#head'
          \ },
          \ 'tabline': {
          \ 'left': [['buffers']],
          \ 'right': [['bufnum']]
          \ },
          \ 'component_expand': {
          \   'buffers': 'lightline#bufferline#buffers',
          \   'cocerror': 'LightLineCocError',
          \   'cocwarn' : 'LightLineCocWarn',
          \ },
          \ 'inactive': {
          \   'left': [['filename']],
          \   'right': []
          \ },
          \ 'component_type': {'buffers': 'tabsel'},
          \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2"},
          \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3"},
          \ 'enable': {'statusline': 1, 'tabline': 1}
          \ }
        " ======================================================
        " ==================== Coc setting =====================
        " ======================================================
        " Use tab for trigger completion with characters ahead and navigate.
        " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
        inoremap <silent><expr> <TAB>
              \ pumvisible() ? "\<C-n>" :
              \ <SID>check_back_space() ? "\<TAB>" :
              \ coc#refresh()
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
        function! s:check_back_space() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction
        " Use <c-space> to trigger completion.
        inoremap <silent><expr> <c-space> coc#refresh()
        " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
        " Coc only does snippet and additional edit on confirm.
        inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
        " Use `[c` and `]c` to navigate diagnostics
        nmap <silent> [c <Plug>(coc-diagnostic-prev)
        nmap <silent> ]c <Plug>(coc-diagnostic-next)
        " Remap keys for gotos
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)
        nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)
        " Use K to show documentation in preview window
        nnoremap <silent> K :call <SID>show_documentation()<CR>
        function! s:show_documentation()
          if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
          else
            call CocActionAsync('doHover')
          endif
        endfunction
        " Remap for rename current word
        nmap <leader>cr <Plug>(coc-rename)
        " Remap for format selected region
        xmap <leader>cf  <Plug>(coc-format-selected)
        nmap <leader>cf  <Plug>(coc-format)
        " Use `:Fold` to fold current buffer
        command! -nargs=? Fold :call     CocActionAsync('fold', <f-args>)
        " Using CocList
        " Show all diagnostics
        nnoremap <silent> <leader>ca  :<C-u>CocList diagnostics<cr>
        " Map function and class text objects
        " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
        xmap if <Plug>(coc-funcobj-i)
        omap if <Plug>(coc-funcobj-i)
        xmap af <Plug>(coc-funcobj-a)
        omap af <Plug>(coc-funcobj-a)
        xmap ic <Plug>(coc-classobj-i)
        omap ic <Plug>(coc-classobj-i)
        xmap ac <Plug>(coc-classobj-a)
        omap ac <Plug>(coc-classobj-a)
        let g:tex_conceal="abdgm"
        " ======================================================
        " ======================= LaTex ========================
        " ======================================================
        let g:livepreview_cursorhold_recompile = 0
        let g:livepreview_use_biber = 1
        " ======================================================
        " ====================== startify ======================
        " ======================================================
        let g:startify_session_persistence=1
        let g:startify_change_to_dir=0
        let g:startify_fortune_use_unicode=1
        let g:startify_lists = [
            \ {'type': 'sessions', 'header': ['Sessions']},
            \ {'type': 'dir', 'header': ['MRU', getcwd()]}
            \ ]
        " ======================================================
        " ===================== Fugitive =======================
        " ======================================================
        nnoremap <silent> <leader>gg :Git<cr>
        nnoremap <silent> <leader>gc :Git commit<cr>
        nnoremap <silent> <leader>gp :Git push<cr>
        nnoremap <silent> <leader>gd :Git diff<cr>
        nnoremap <silent> <leader>gf :Git pull<cr>
        " ======================================================
        " ===================== NerdTree =======================
        " ======================================================
        nnoremap <silent> <C-n> :NERDTreeFocus<cr>
        " ======================================================
        " ==================== Path for NixOS ==================
        " ======================================================
        let g:coc_node_path = '${pkgs.nodejs}/bin/node' 
        let g:coc_user_config = {
          \'rust-analyzer': {
          \  'serverPath': $RUST_ANALYZER_PATH,
          \  'inlayHints.chainingHints': 0,
          \  'checkOnSave.command': 'clippy',
          \  'rustfmt': {
          \    'enableRangeFormatting': 1
          \  }
          \},
          \'python': {
          \  'venvPath': [$VIRTUAL_ENV],
          \},
          \'languageserver': {
          \  'nix': {
          \    'command': '${pkgs.rnix-lsp}/bin/rnix-lsp',
          \    'filetypes': ['nix']
          \  },
          \  'ccls': {
          \    'command': $CCLS_PATH,
          \    'filetypes': ['c', 'cc', 'cpp', 'c++', 'objc', 'objcpp'],
          \    'rootPatterns': ['.ccls', 'compile_commands.json', '.git/', '.hg/'],
          \    'initializationOptions': {
          \      'cache': {
          \        'directory': '.ccls-cache'
          \      },
          \      'index': {
          \        'comment': 2
          \      }
          \    }
          \  }
          \},
          \'diagnostic.checkCurrentLine': 1,
          \'diagnostic.warningSign': "*",
          \'suggest.enablePreview': 1
        \}
        hi MatchParen      ctermfg=208 ctermbg=0 cterm=bold
        autocmd FileType python let b:coc_root_patterns = ['.git', '.env', 'setup.py']

        " Find files using Telescope command-line sugar.
        nnoremap <leader>ff <cmd>Telescope find_files<cr>
        nnoremap <leader>fg <cmd>Telescope live_grep<cr>
        nnoremap <leader>fb <cmd>Telescope buffers<cr>
        nnoremap <leader>fh <cmd>Telescope help_tags<cr>

        " ======================================================
        " ====================== DAP ===========================
        " ======================================================
        nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
        nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
        nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
        nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>
        nnoremap <silent> <leader>b :lua require'dap'.toggle_breakpoint()<CR>
        nnoremap <silent> <leader>B :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
        nnoremap <silent> <leader>lp :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
        nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
        nnoremap <silent> <leader>dl :lua require'dap'.run_last()<CR>

        lua <<EOF
        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = true,
          },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "gnn",
              node_incremental = "grn",
              scope_incremental = "grc",
              node_decremental = "grm",
            },
          },
          textobjects = {
            select = {
              enable = true,

              -- Automatically jump forward to textobj, similar to targets.vim
              lookahead = true,

              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
              },
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
        }

        require'treesitter-context'.setup{
          enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
          throttle = true, -- Throttles plugin updates (may improve performance)
          max_lines = 4, -- How many lines the window should span. Values <= 0 mean no limit.
          patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
            -- For all filetypes
            -- Note that setting an entry here replaces all other patterns for this entry.
            -- By setting the 'default' entry below, you can control which nodes you want to
            -- appear in the context window.
            default = {
                'class',
                'function',
                'method',
                'for',
                'while',
                'if',
                'switch',
                'case',
            },
            rust = {
                'impl_item',
                'match_arm'
            }
          }
        }

        local dap = require('dap')
        handle = io.popen([[rustc --print sysroot]])
        sysroot = handle:read('*a'):gsub('^(.-)%s*$', '%1')

        script_import = 'command script import ' .. sysroot .. '/lib/rustlib/etc/lldb_lookup.py'
        commands_file = sysroot .. '/lib/rustlib/etc/lldb_commands'

        dap.adapters.lldb = {
          type = 'executable',
          command = 'lldb-vscode',
          name = "lldb",
        }
        dap.configurations.cpp = {
          {
            name = 'Launch',
            type = 'lldb',
            request = 'launch',
            program = function()
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = "''${workspaceFolder}",
            stopOnEntry = false,
            args = {},
            runInTerminal = false,
          },
        }
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp

        require('neoscroll').setup()
        require("zen-mode").setup()
        EOF
      '';
    };
  }
