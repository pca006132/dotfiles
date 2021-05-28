{ pkgs
, pkgs-unstable ? import <nixpkgs-unstable> {}
, extra-pkgs ? []
, ...
}:
let
  mynvim = import ./nvim.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    # Misc
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
    pkgs-unstable.fzf
    (texlive.combine {
      inherit (texlive)
      scheme-full
      minted;
    })
    hyperfine
    (python38.withPackages (
      ps: with ps; [
        numpy
        pygments
        matplotlib
        scipy
        ipython
        jupyter
        pytest
        jedi
      ]
      ))
  ] ++ [
    mynvim
  ] ++ extra-pkgs;

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  home.sessionVariables = {
    "EDITOR" = "nvim";
  };

  programs.home-manager = {
    enable = true;
  };
  home.stateVersion = "20.09";

  fonts.fontconfig.enable = true;

  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
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
      pull = {
        ff = "only";
      };
    };
    userEmail = "john.lck40@gmail.com";
    userName = "pca006132";
    ignores = [ ".envrc" ".direnv/" ".venv" ];
    signing = {
      key = "E9D2B552F9801C5D";
      signByDefault = false;
    };
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    defaultCacheTtlSsh = 60;
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    sshKeys = [ "996D13DF48B5A21F57298DD1B542F46ABECF3015" ];
  };

  programs.zsh = {
    enable = true;
    initExtra = ''
      source /etc/profile
      task | awk '{ z = '$(tput cols)' - length; y = int(z / 2); x = z - y; printf "%*s%s%*s\n", x, "", $0, y, ""; }'
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
    plugins = with pkgs.tmuxPlugins; [ vim-tmux-navigator ];
    shortcut = "a";
    terminal = "xterm";
  };

  programs.taskwarrior = {
    enable = true;
  };
}
