{ pkgs , pkgs-unstable, neovim-nightly-overlay, ... }:
let
  mynvim = import ./nvim.nix { inherit pkgs pkgs-unstable; };
in
{
  home.packages = with pkgs; [
    # Misc
    dconf
    gcc
    pkg-config
    git
    tealdeer
    powerline-fonts
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
    mynvim
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

  fonts.fontconfig.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    nix-direnv.enableFlakes = true;
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
}
