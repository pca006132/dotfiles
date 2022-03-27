{ pkgs, pkgs-unstable, neovim-nightly-overlay, ... }:
let
  luaSetup = plugin: name: {
    plugin = plugin;
    config = "require('${name}').setup()";
    type = "lua";
  };
  cmp-copilot = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-copilot";
    version = "2021-11-05";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-copilot";
      rev = "104f6784351911d39e11f4edeaf43dc9ecc23cc2";
      sha256 = "0fa6a3m5hf3f7pdbmkb4dnczvcvr6rr3pshvdwkqy62v08h1vdyk";
    };
  };

in
{
  home.packages = with pkgs; [
    # Misc
    dconf
    gcc
    pkg-config
    git
    tealdeer
    fd
    bat
    aria2
    ripgrep
    ydiff
    nodejs
    ranger
    xclip
    sshfs
    neovide
    pkgs-unstable.fzf
    (
      texlive.combine {
        inherit (texlive)
          scheme-full
          minted
          ;
      }
    )
    hyperfine
    (
      python38.withPackages (
        ps: with ps; [
          numpy
          pygments
          matplotlib
          scipy
          ipython
          jupyter
          pytest
          autopep8
        ]
      )
    )
    (nerdfonts.override { fonts = ["DejaVuSansMono" "Hack"]; })
  ];

  nixpkgs.overlays = [
    neovim-nightly-overlay.overlay
  ];

  home.sessionVariables = {
    "EDITOR" = "nvim";
  };

  programs.home-manager = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "DejaVuSansMono";
      size = 12;
    };
  };

  fonts.fontconfig.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  services.pulseeffects = {
    enable = true;
    package = pkgs.pulseeffects-pw;
  };

  programs.git = {
    enable = true;
    delta.enable = true;
    extraConfig = {
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      pull = {
        ff = "only";
      };
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
    publicKeys = [
      { source = ./public.key; trust = 5; }
    ];
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
      plugins = [
        "git"
        "z"
        "vi-mode"
        "history-substring-search"
      ];
      theme = "avit";
    };
    autocd = true;
    shellAliases = {
      ll = "ls -l";
      v = "nvim";
      r = "ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd \"$LASTDIR\"";
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
    package = pkgs-unstable.neovim.unwrapped;
    extraConfig = ''
      source ${builtins.toString ./nvim/basic.vim}
      source ${builtins.toString ./nvim/keymaps.vim}
      luafile ${builtins.toString ./nvim/lsp.lua}
      " fugitive
      nnoremap <silent> <leader>gg :Git<cr>
      nnoremap <silent> <leader>gc :Git commit<cr>
      nnoremap <silent> <leader>gp :Git push<cr>
      nnoremap <silent> <leader>gd :Git diff<cr>
      nnoremap <silent> <leader>gf :Git pull<cr>
      " lightline
      let g:lightline = {
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \             [ 'gitbranch', 'cocstatus', 'readonly', 'filename', 'modified' ] ]
        \ },
        \ 'component_function': {
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
    " tex live preview
    let g:livepreview_cursorhold_recompile = 0
    let g:livepreview_use_biber = 1
    " molokai
    let g:molokai_original = 0
    colo molokai
    hi MatchParen  guifg=254 guifg=208 gui=bold ctermfg=208 ctermbg=0 cterm=bold
    hi EndOfBuffer ctermfg=bg guifg=bg
    hi SignColumn guibg=bg
    hi SignColumn ctermbg=bg
    hi Conceal ctermbg=233
    hi Comment ctermfg=gray
    " startify
    let g:startify_session_persistence=1
    let g:startify_change_to_dir=0
    let g:startify_fortune_use_unicode=1
    let g:startify_lists = [
        \ {'type': 'sessions', 'header': ['Sessions']},
        \ {'type': 'dir', 'header': ['MRU', getcwd()]}
        \ ]
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
    hi GitSignsAdd guifg=Green ctermfg=Green
    hi GitSignsDelete guifg=Red ctermfg=Red
    hi GitSignsChange guifg=Yellow ctermfg=Yellow
    hi GitSignsModify guifg=Yellow ctermfg=Yellow
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
    " lightbulb
    autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
    '';
    plugins = with pkgs-unstable.vimPlugins; [
      plenary-nvim
      dressing-nvim
      (luaSetup nvim-tree-lua "nvim-tree")
      nvim-web-devicons
      vim-fugitive
      vim-commentary
      vim-surround
      lightline-vim
      lightline-bufferline
      vim-polyglot
      vimtex
      vim-tmux-navigator
      molokai
      vim-startify
      delimitMate
      telescope-nvim
      indent-blankline-nvim
      lightspeed-nvim
      nvim-dap
      (luaSetup neoscroll-nvim "neoscroll")
      (luaSetup zen-mode-nvim "zen-mode")
      (luaSetup gitsigns-nvim "gitsigns")
      copilot-vim
      pkgs.vimPlugins.nvim-treesitter-textobjects
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-path
      cmp-buffer
      cmp-copilot
      nvim-lightbulb
      (luaSetup fidget-nvim "fidget")
      {
        plugin = lsp_lines-nvim;
        config = ''
          require("lsp_lines").register_lsp_virtual_lines()
        '';
        type = "lua";
      }
      {
        plugin = pkgs.vimPlugins.nvim-treesitter;
        config = ''
          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
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
      {
        plugin = pkgs.vimPlugins.nvim-treesitter-context;
        config = ''
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
        '';
        type = "lua";
      }
      {
        plugin = nvim-dap-ui;
        optional = true;
      }
      {
        plugin = vim-latex-live-preview;
        optional = true;
      }
    ];
  };
}
