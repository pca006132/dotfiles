{ pkgs, ... }:
let
  mynvim = import ./nvim.nix { inherit pkgs; };
  pkgs-unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};
in
{
  home.packages = with pkgs; [
    # Misc
    pkg-config
    git
    tldr
    material-design-icons
    powerline-fonts
    fd
    bat
    aria2
    tldr
    ripgrep
    ydiff
    nodejs
    ranger
    xclip
    fzf
    (
      pkgs.iosevka.override {
        privateBuildPlan = {
          family = "Iosevka";
          design = [
            "sans"
            "expanded"
            "ligset-haskell"
            # for some reason, ss12 does not work
            "v-at-threefold"
            "v-a-doublestorey"
            "v-f-straight"
            "v-underscore-low"
            "v-i-italic"
            "v-k-straight"
            "v-l-italic"
            "v-m-shortleg"
            "v-y-straight-turn"
            "v-brace-straight"
            "v-zero-dotted"
            "v-one-base"
            "v-numbersign-slanted"
            "v-six-open-contour"
            "v-nine-open-contour"
          ];
        };
        set = "Iosevka";
      }
    )
    (
      pkgs-unstable.python38.withPackages
        (
          ps: with ps; [
            numpy
            scipy
            matplotlib
            regex
            jsbeautifier
          ]
        )
    )
  ] ++ [
    mynvim
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
    '';
    enableAutosuggestions = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "z"
        "vi-mode"
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
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
    '';
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [ vim-tmux-navigator ];
    shortcut = "a";
    terminal = "xterm";
  };
}
