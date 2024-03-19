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
    sioyek
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
    inputs.emanote.packages.x86_64-linux.emanote
    zotero
    languagetool
  ] ++ inputs.my-nvim.nvim-stuff;
  desktop-apps = with pkgs; [
    rime-data
    firefox-bin
    nvtop
    intel-gpu-tools
    pinentry-qt
    vlc
    thunderbird
    inputs.nix-gaming.packages.${pkgs.hostPlatform.system}.osu-lazer-bin
    zoom-us
  ];
in
{
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "22.11";
  programs.home-manager = { enable = true; };

  home.packages = with pkgs; [
    (callPackage ./prusa-slicer.nix { })
  ] ++ development-packages ++ tools ++ desktop-apps;

  xdg.desktopEntries = {
    prusa-slicer = {
      name = "Prusa Slicer";
      exec = "prusa-slicer";
      icon = "prusa-slicer";
      comment = "Prusa Slicer";
      genericName = "3D printer tool";
      categories = [ "Development" ];
    };
  };

  xdg.dataFile."fcitx5/rime" = {
    recursive = true;
    source = inputs.rime-ice;
  };
  xdg.dataFile."fcitx5/rime/rime_ice.custom.yaml" = {
    text = ''
      patch:
        translator.always_show_comments: false
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:/run/opengl-driver/lib";
    ZK_NOTEBOOK_DIR = "$HOME/notebook";
    BIBINPUTS = "$HOME/texmf/bibtex/bib"; # Zotero bib path
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
    inputs.neovim-nightly-overlay.overlay
    inputs.nix-alien.overlays.default
    (self: super: {
      neovim-unwrapped = super.neovim-unwrapped.overrideAttrs (oa: {
        patches = builtins.filter
          (p:
            let
              patch =
                if builtins.typeOf p == "set"
                then baseNameOf p.name
                else baseNameOf p;
            in
            patch != "neovim-build-make-generated-source-files-reproducible.patch")
          oa.patches;
      });
    })
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

  services.gpg-agent = {
    defaultCacheTtlSsh = 60;
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    sshKeys = [ "996D13DF48B5A21F57298DD1B542F46ABECF3015" ];
    pinentryFlavor = "qt";
  };

  programs.ssh = {
    enable = true;
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
    initExtra = ''
      if [[ "$SSH_AUTH_SOCK" == "/run/user/1000/keyring/ssh" ]]
      then
        SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) 
      fi
    '';
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
