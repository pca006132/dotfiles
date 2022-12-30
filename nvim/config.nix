{ pkgs, inputs, ... }:
let
  luaSetup = plugin: name: {
    plugin = plugin;
    config = "require('${name}').setup()";
    type = "lua";
  };
  lspkind = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "lspkind";
    version = "0.1.0";
    src = inputs.lspkind-src;
  };
  alpha-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "alpha-nvim";
    version = "0.1.0";
    src = inputs.alpha-nvim-src;
  };
  monokai-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "monokai-nvim";
    version = "0.1.0";
    src = inputs.monokai-nvim-src;
  };
  rust-tools-nvim-latest = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "rust-tools-nvim";
    version = "0.1.0";
    src = inputs.rust-tools-nvim-src;
  };
  tabout-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "tabout-nvim";
    version = "0.1.0";
    src = inputs.tabout-nvim-src;
  };
  knap-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "knap-nvim";
    version = "0.1.0";
    src = inputs.knap-nvim-src;
  };
  session-manager = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "session-manager";
    version = "0.1.0";
    src = inputs.session-manager-src;
  };
in
{
  programs.neovim = {
    enable = true;
    extraConfig = ''
      lua require('impatient').enable_profile()
      lua vim.notify = require("notify")
      source ${./basic.vim}
      source ${./keymaps.vim}
      source ${./highlight.vim}
      luafile ${./lsp.lua}
      " fugitive
      nnoremap <silent> <leader>gg :Git<cr>
      nnoremap <silent> <leader>gc :Git commit<cr>
      nnoremap <silent> <leader>gp :Git push<cr>
      nnoremap <silent> <leader>gd :Git diff<cr>
      nnoremap <silent> <leader>gf :Git pull<cr>
      " nvim-gps
      func! NvimGps() abort
        return luaeval("require'nvim-gps'.is_available()") ?
             \ luaeval("require'nvim-gps'.get_location()") : ""
      endf
      " lightline
      let g:lightline = {
        \ 'active': {
        \   'left': [ [ 'mode', 'paste', 'nvim-gps'],
        \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
        \ },
        \ 'component_function': {
        \   'gitbranch': 'FugitiveHead',
        \   'nvim-gps': 'NvimGps'
        \ },
        \ 'tabline': {
        \   'left': [['buffers']],
        \   'right': [['bufnum']]
        \ },
        \ 'component_expand': {
        \   'buffers': 'lightline#bufferline#buffers',
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
        " tex live preview
        let g:livepreview_cursorhold_recompile = 0
        let g:livepreview_use_biber = 1
        " telescope
        nnoremap <leader>ff <cmd>Telescope find_files<cr>
        nnoremap <leader>fg <cmd>Telescope live_grep<cr>
        nnoremap <leader>fb <cmd>Telescope buffers<cr>
        nnoremap <leader>fh <cmd>Telescope help_tags<cr>
        " debug adapter
        nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
        nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
        nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
        nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>
        nnoremap <silent> <leader>b :lua require'dap'.toggle_breakpoint()<CR>
        nnoremap <silent> <leader>B :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
        nnoremap <silent> <leader>lp :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
        nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
        nnoremap <silent> <leader>dl :lua require'dap'.run_last()<CR>
        " gitsigns
        highlight DiffAdd guifg=Green ctermfg=Green
        highlight DiffDelete guifg=Red ctermfg=Red
        highlight DiffChange guifg=Yellow ctermfg=Yellow
        " nvim tree
        nnoremap <C-n> :NvimTreeToggle<CR>
        nnoremap <leader>r :NvimTreeRefresh<CR>
        nnoremap <leader>n :NvimTreeFindFile<CR>
        " nvim-cmp
        highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
        highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
        highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
        highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
        highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
        highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
        highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
        highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
        highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
        highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
        highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
        " neoformat
        nnoremap <leader>cf :Neoformat<CR>
    '';
    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      dressing-nvim
      {
        plugin = nvim-tree-lua;
        config = ''
        require("nvim-tree").setup({
          renderer = {
            group_empty = true
          }
        })
        '';
        type = "lua";
      }
      nvim-web-devicons
      vim-fugitive
      (luaSetup comment-nvim "Comment")
      vim-surround
      lightline-vim
      lightline-bufferline
      vim-polyglot
      vimtex
      vim-tmux-navigator
      neoformat
      impatient-nvim
      vim-vsnip
      vim-vsnip-integ
      nvim-notify
      {
        plugin = knap-nvim;
        config = ''
          local gknapsettings = {
              texoutputext = "pdf",
              textopdf = "pdflatex -synctex=1 -halt-on-error -interaction=batchmode %docroot%",
              textopdfviewerlaunch = "sioyek --inverse-search 'nvim --headless -es --cmd \"lua require('\"'\"'knaphelper'\"'\"').relayjump('\"'\"'%servername%'\"'\"','\"'\"'%1'\"'\"',%2,0)\"' --reuse-instance %outputfile%",
              textopdfviewerrefresh = "none",
              textopdfforwardjump = "sioyek --inverse-search 'nvim --headless -es --cmd \"lua require('\"'\"'knaphelper'\"'\"').relayjump('\"'\"'%servername%'\"'\"','\"'\"'%1'\"'\"',%2,0)\"' --reuse-instance --forward-search-file %srcfile% --forward-search-line %line% %outputfile%"
          }
          vim.g.knap_settings = gknapsettings
          local kmap = vim.keymap.set
          kmap('n','<F7>', function() require("knap").toggle_autopreviewing() end)
          kmap('i','<F8>', function() require("knap").forward_jump() end)
          kmap('v','<F8>', function() require("knap").forward_jump() end)
          kmap('n','<F8>', function() require("knap").forward_jump() end)
        '';
        type = "lua";
      }
      {
        plugin = session-manager;
        config = ''
          local Path = require('plenary.path')
          require('session_manager').setup({
            sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
            path_replacer = '__', -- The character to which the path separator will be replaced for session files.
            colon_replacer = '++', -- The character to which the colon symbol will be replaced for session files.
            autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
            autosave_last_session = true, -- Automatically save last session on exit and on session switch.
            autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
            autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
              'gitcommit',
            },
            autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
            max_path_length = 80,  -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
          })
        '';
        type = "lua";
      }
      {
        plugin = monokai-nvim;
        config = ''
          local monokai = require('monokai')
          local palette = monokai.pro
          monokai.setup {
            palette = palette,
            custom_hlgroups = {
              GitSignsAdd = {
                fg = palette.green,
                bg = palette.base2
              },
              GitSignsDelete = {
                fg = palette.pink,
                bg = palette.base2
              },
              GitSignsChange = {
                fg = palette.orange,
                bg = palette.base2
              },
            }
          }
        '';
        type = "lua";
      }
      {
        plugin = alpha-nvim;
        config = ''
          local alpha = require'alpha'
          local startify = require'alpha.themes.startify'
          startify.section.top_buttons.val = {
              startify.button( "e", "  New file" , ":ene <BAR> startinsert <CR>"),
          }
          -- disable MRU
          startify.section.mru.val = { { type = "padding", val = 0 } }
          startify.section.bottom_buttons.val = {
              startify.button( "q", "  Quit NVIM" , ":qa<CR>"),
          }
          startify.section.footer = {
              { type = "text", val = "footer" },
          }
          alpha.setup(startify.config)
        '';
        type = "lua";
      }
      {
        plugin = vim-markdown;
        config = ''
          let g:vim_markdown_math = 1
        '';
        type = "viml";
      }
      delimitMate
      telescope-nvim
      lightspeed-nvim
      nvim-dap
      (luaSetup zen-mode-nvim "zen-mode")
      (luaSetup gitsigns-nvim "gitsigns")
      lspkind
      nvim-treesitter-textobjects
      nvim-ts-rainbow
      nvim-lspconfig
      (luaSetup lspsaga-nvim "lspsaga")
      nvim-cmp
      cmp-nvim-lsp
      cmp-path
      cmp-buffer
      cmp-latex-symbols
      lsp_signature-nvim
      rust-tools-nvim-latest
      codi-vim
      tabout-nvim
      vim-sleuth
      (luaSetup nvim-gps "nvim-gps")
      (luaSetup fidget-nvim "fidget")
      {
        plugin = nvim-treesitter.withPlugins (plugins: with plugins; [
          tree-sitter-c
          tree-sitter-nix
          tree-sitter-json
          tree-sitter-haskell
          tree-sitter-typescript
          tree-sitter-html
          tree-sitter-cuda
          tree-sitter-bash
          tree-sitter-latex
          tree-sitter-cmake
          tree-sitter-python
          tree-sitter-rust
        ]);
        config = ''
          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
            },
            rainbow = {
              enable = true,
              extended_mode = true,
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
        '';
        type = "lua";
      }
      nvim-dap-ui
      {
        plugin = vim-latex-live-preview;
        config = ''
          let g:livepreview_engine = 'xelatex'
        '';
        type = "viml";
      }
    ];
  };
}
