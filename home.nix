{ pkgs
, config
, inputs
, ...
}:
let
  development-packages = with pkgs; [
    gnumake
    clang-tools_16 # default clang is 16
    cmake
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
    (texlive.combine {
      inherit (texlive) scheme-full minted beamertheme-arguelles;
    })
    tectonic
    vale
    powertop
    nodePackages.pyright
    nodePackages.typescript
    nodePackages_latest.typescript-language-server
    nil
    (python3.withPackages (ps:
      with ps; [
        numpy
        matplotlib
        scipy
        pandas
        requests
        grequests
        setuptools
        black
      ]))
    rs-git-fsmonitor
    rnote
    bind
  ];
  tools = with pkgs; [
    tealdeer
    fd
    sd
    bat
    aria2
    ripgrep
    ranger
    fzf
    imagemagick
    vimv
    pandoc
    pdftk
    nix-du
    nix-prefetch-git
    graphviz
    yt-dlp
    rsync
    unar
    zip
    xournalpp
    wl-clipboard
    tree
    shntool
    flac
    nix-alien
    quickemu
    quickgui
    spice-gtk
    gh
    inotify-tools
    tikzit
    zk
    zotero
    languagetool
    inkscape
    beamerpresenter
  ] ++ inputs.my-nvim.nvim-stuff;
  desktop-apps = with pkgs; [
    rime-data
    firefox-bin
    nvtopPackages.full
    intel-gpu-tools
    pinentry-qt
    vlc
    thunderbird
    inputs.nix-gaming.packages.${pkgs.hostPlatform.system}.osu-lazer-bin
    zoom-us
    onlyoffice-bin
    obs-studio
    avidemux
    anki-bin

    steam
    protonup-qt
  ];
in
{
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "22.11";
  programs.home-manager = { enable = true; };

  home.packages = with pkgs; [
    # (callPackage ./prusa-slicer.nix { })
    (qt6.callPackage ./sioyek.nix { })
  ] ++ development-packages ++ tools ++ desktop-apps;

  xdg = {
    dataFile = {
      "fcitx5/rime" = {
        recursive = true;
        source = inputs.rime-ice;
      };
      "fcitx5/rime/rime_ice.custom.yaml" = {
        text = ''
          patch:
            traditionalize/opencc_config: s2hk.json
        '';
      };
    };
    configFile = {
      "neovide/config.toml" = {
        text = ''
          fork=true
        '';
      };
    };
    mimeApps.defaultApplications = {
      "application/pdf" = "sioyek.desktop";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:/run/opengl-driver/lib";
    BIBINPUTS = "$HOME/texmf/bibtex/bib"; # Zotero bib path
  };
  home.sessionPath = [ "$HOME/.npm-packages/bin/" "$HOME/.local/bin" ];


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
      (text "DiskIO")
      (text "NetworkIO")
    ]) // (with config.lib.htop; rightMeters [
      (bar "RightCPUs2")
      (text "Tasks")
      (text "LoadAverage")
      (text "Uptime")
      (text "Systemd")
    ]);
  };

  fonts.fontconfig.enable = true;

  nixpkgs.overlays = [
    inputs.nix-alien.overlays.default
  ];

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
        preloadIndex = true;
        fsmonitor = "rs-git-fsmonitor";
      };
      pull = { ff = "only"; };
      push = { autoSetupRemote = true; };
      submodule.fetchJobs = 8;
    };
    difftastic.enable = true;
    lfs.enable = true;
    userEmail = "john.lck40@gmail.com";
    userName = "pca006132";
    ignores = [ ".envrc" ".direnv/" ".venv" ];
  };

  services.easyeffects = {
    enable = true;
  };

  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      pca-pc = {
        hostname = "pca006132.duckdns.org";
        forwardAgent = true;
        compression = true;
      };
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
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

  programs.neovim = inputs.my-nvim.nvim;
}
