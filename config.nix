{ inputs }:
{ pkgs
, config
, ...
}:
let
  development-packages = with pkgs; [
    gnumake
    clang-tools
    cmake
    gdb
    kcachegrind
    pkg-config
    flamegraph
    linuxPackages.perf
    hyperfine

    gcc
    nodejs
    metals
    sbt
    scalafmt

    nixpkgs-fmt

    texlab
    (texlive.combine { inherit (texlive) scheme-full minted; })

    languagetool
    vale

    nodePackages.pyright
    (python3.withPackages (ps:
      with ps; [
        numpy
        matplotlib
        scipy
        autopep8
      ]))
  ];
  tools = with pkgs; [
    tealdeer
    fd
    sd
    bat
    aria2
    ripgrep
    ranger
    xclip
    neovide
    fzf
    sioyek
    imagemagick
    vimv
    pandoc
    pdftk
    nix-du
    nix-prefetch-git
    xdot
    graphviz
    yt-dlp
    rsync
    unar
  ];
  desktop-apps = with pkgs; [
    rime-data
    firefox-bin
    zoom-us
    gnome.adwaita-icon-theme
    gnomeExtensions.dash-to-dock
    (nerdfonts.override { fonts = [ "DejaVuSansMono" "Hack" ]; })
  ];
in
{
  programs.home-manager = { enable = true; };

  home.packages = with pkgs; [
    osu-lazer
  ] ++ development-packages ++ tools ++ desktop-apps;

  home.sessionVariables = {
    EDITOR = "nvim";
    GSM_SKIP_SSH_AGENT_WORKAROUND = "1";
  };
  home.sessionPath = [ "$HOME/.npm-packages/bin/" "$HOME/.local/bin" ];

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = "sioyek.desktop";
  };

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

  programs.htop = {
    enable = true;
    settings = {
      show_cpu_usage = 1;
      show_cpu_frequency = 1;
      show_cpu_temperature = 1;
    } // (with config.lib.htop; leftMeters [
      (bar "LeftCPUs2")
      (bar "Memory")
      (bar "Swap")
      (bar "DiskIO")
      (bar "NetworkIO")
    ]) // (with config.lib.htop; rightMeters [
      (bar "RightCPUs2")
      (text "Tasks")
      (text "LoadAverage")
      (text "Uptime")
      (text "Systemd")
    ]);
  };

  fonts.fontconfig.enable = true;

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-rime ];
  };
  home.file.".config/environment.d/envvars.conf".text = ''
    GTK_IM_MODULE=fcitx
    QT_IM_MODULE=fcitx
    XMODIFIERS=@im=fcitx
  '';

  nixpkgs.overlays = [ inputs.neovim-nightly-overlay.overlay ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
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

  services.easyeffects = {
    enable = true;
  };
  # xdg.configFile."easyeffects/output" = {
  #   recursive = true;
  #   source = inputs.easyeffects-presets;
  # };

  services.gpg-agent = {
    defaultCacheTtlSsh = 60;
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    sshKeys = [ "996D13DF48B5A21F57298DD1B542F46ABECF3015" ];
  };

  programs.zsh = {
    enable = true;
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
}
