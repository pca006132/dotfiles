{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, neovim-nightly-overlay, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages."${system}".extend
        neovim-nightly-overlay.overlays.default;
      luaSetup = plugin: name: {
        plugin = plugin;
        config = "require('${name}').setup()";
        type = "lua";
      };
      getPlugin = name: pkgs.vimUtils.buildVimPlugin {
        pname = name;
        version = "0.1.0";
        src = inputs."${name}-src";
      };
      plugins = pkgs.lib.attrsets.mapAttrs'
        (key: value: rec {
          name = pkgs.lib.strings.removeSuffix "-src" key;
          value = getPlugin name;
        })
        (pkgs.lib.attrsets.filterAttrs
          (name: _: pkgs.lib.strings.hasSuffix "-src"
            name)
          inputs);
    in
    {
      nvim = {
        enable = true;
        package = pkgs.neovim;
        extraConfig = ''
          lua vim.loader.enable()
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
          " lightline
          let g:lightline = {
            \ 'active': {
            \   'left': [ [ 'mode', 'paste'],
            \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
            \ },
            \ 'component_function': {
            \   'gitbranch': 'FugitiveHead'
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
            " nvim tree
            nnoremap <C-n> :Neotree toggle reveal<CR>
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
            let g:neoformat_enabled_python = ['black']
            " easy-align
            xmap ga <Plug>(EasyAlign)

            let g:vimtex_view_method = 'zathura_simple'
            let g:vimtex_callback_progpath = "/etc/profiles/per-user/pca006132/bin/nvim"
            let g:vimtex_quickfix_open_on_warning = 0
        '';
        plugins = with pkgs.vimPlugins; with plugins; [
          Coqtail
          plenary-nvim
          dressing-nvim
          {
            plugin = neo-tree-nvim;
            config = ''
              require("neo-tree").setup({})
            '';
            type = "lua";
          }
          {
            plugin = catppuccin-nvim;
            config = ''
              vim.cmd[[colorscheme catppuccin-mocha]]
            '';
            type = "lua";
          }
          vim-gitgutter
          vim-easy-align
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
          vim-vsnip
          vim-vsnip-integ
          parinfer-rust
          nvim-notify
          zk-nvim
          # knap
          alpha-nvim
          {
            plugin = vim-markdown;
            type = "viml";
          }
          delimitMate
          telescope-nvim
          lightspeed-nvim
          nvim-dap
          lspkind-nvim
          nvim-treesitter-textobjects
          nvim-lspconfig
          lspsaga-nvim
          nvim-cmp
          cmp-nvim-lsp
          cmp-path
          cmp-buffer
          cmp-latex-symbols
          lsp_signature-nvim
          codi-vim
          vim-sleuth
          typst-vim
          (luaSetup fidget-nvim "fidget")
          {
            plugin = (nvim-treesitter.withPlugins
              (plugins: with plugins; [
                c
                cpp
                nix
                json
                haskell
                typescript
                html
                bash
                latex
                python
                rust
                markdown
                java
                typst
              ]));
            config = ''
              require'nvim-treesitter.configs'.setup {
                highlight = {
                  enable = true,
                  additional_vim_regex_highlighting = { "markdown" }
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
          (luaSetup tabout-nvim "tabout")
        ];
      };
      nvim-stuff = with pkgs; [
        typst
        typstyle
        tinymist
        neovide
        gdb
      ];
    };
}
