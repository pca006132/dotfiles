{ pkgs
, inputs
, ...
}:
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
in
{
  home.packages = with pkgs; [
    # Misc
    gcc
    pkg-config
    tealdeer
    fd
    sd
    bat
    aria2
    ripgrep
    ydiff
    nodejs
    ranger
    xclip
    sshfs
    neovide
    fzf
    (texlive.combine { inherit (texlive) scheme-full minted; })
    texlab
    gnomeExtensions.dash-to-dock
    hyperfine
    nixpkgs-fmt
    powertop
    kcachegrind
    linuxPackages.perf
    evince
    osu-lazer
    cachix
    chromium
    f3d
    flamegraph
    gdb
    imagemagick
    gotop
    killall
    nix-du
    nix-prefetch-git
    pandoc
    pdftk
    marktext
    vimv
    yt-dlp
    rsync
    languagetool
    vale
    clang-tools
    graphviz
    solaar
    xournalpp
    xdot
    (python3.withPackages (ps:
      with ps; [
        numpy
        pygments
        matplotlib
        scipy
        autopep8
        sympy
        mutagen
      ]))
    nodePackages.pyright
    (nerdfonts.override { fonts = [ "DejaVuSansMono" "Hack" ]; })
  ];

  home.sessionVariables = {
    "EDITOR" = "nvim";
    # work around home-manager#3263
    "SSH_AUTH_SOCK" =
      "$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)";
  };
  home.sessionPath = [ "$HOME/.npm-packages/bin/" ];

  programs.home-manager = { enable = true; };

  programs.kitty = {
    enable = true;
    font = {
      name = "DejaVuSansMono";
      size = 12;
    };
    settings = {
      scrollback_lines = 100000;
      enable_audio_bell = false;
      update_check_interval = 0;
    };
  };

  fonts.fontconfig.enable = true;

  nixpkgs.overlays = [ inputs.neovim-nightly-overlay.overlay ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    delta.enable = true;
    extraConfig = {
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      pull = { ff = "only"; };
    };
    lfs.enable = true;
    userEmail = "john.lck40@gmail.com";
    userName = "pca006132";
    ignores = [ ".envrc" ".direnv/" ".venv" ];
    signing = {
      key = "E9D2B552F9801C5D";
      signByDefault = false;
    };
  };

  programs.gpg = {
    enable = true;
    publicKeys = [{
      source = ./public.key;
      trust = 5;
    }];
  };

  services.gpg-agent = {
    defaultCacheTtlSsh = 60;
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = false;
    sshKeys = [ "996D13DF48B5A21F57298DD1B542F46ABECF3015" ];
  };

  programs.zsh = {
    enable = true;
    initExtra = ''
      source /etc/profile
    '';
    enableAutosuggestions = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "z" "vi-mode" "history-substring-search" ];
      theme = "avit";
    };
    autocd = true;
    shellAliases = {
      ll = "ls -l";
      v = "nvim";
      r = ''
        ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'';
    };
  };

  programs.tmux = {
    enable = true;
    escapeTime = 0;
    extraConfig = ''
      set -g mouse on
      set -g default-terminal "tmux-256color"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind t new
    '';
    keyMode = "vi";
    plugins = [ pkgs.tmuxPlugins.vim-tmux-navigator ];
    shortcut = "a";
    terminal = "xterm";
  };

  programs.neovim = {
    enable = true;
    extraConfig = ''
      lua require('impatient').enable_profile()
      lua vim.notify = require("notify")
      source ${builtins.toString ./nvim/basic.vim}
      source ${builtins.toString ./nvim/keymaps.vim}
      source ${builtins.toString ./nvim/highlight.vim}
      luafile ${builtins.toString ./nvim/lsp.lua}
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
      (luaSetup nvim-tree-lua "nvim-tree")
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
          -- startify.section.mru_cwd.val[4].val = function()
          --     return { startify.mru(0, vim.fn.getcwd()) }
          -- end
          -- table.remove(startify.config.layout, 5)
          --
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
      {
        plugin = nvim-lint;
        config = ''
          require('lint').linters.languagetool.cmd= "languagetool-commandline"

          require('lint').linters_by_ft = {
            markdown = {'vale', 'languagetool'}
          }

          vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            callback = function()
              require("lint").try_lint()
            end,
          })
        '';
        type = "lua";
      }
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
