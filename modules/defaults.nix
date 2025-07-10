{ config, lib, pkgs, pkgs-unstable, ... }:
{
  config = {
    nixpkgs = {
      overlays = [
        (final: prev: {
          opentabletdriver = pkgs-unstable.opentabletdriver;
        })
      ];
      config = {
        allowUnfree = true;
        hostPlatform = "x86_64-linux";
      };
    };
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
      kernelModules = [ "coretemp" ];
      kernelParams = [
        "mem_sleep_default=deep"
        "quiet"
      ];
      # kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_stable;
      kernel.sysctl = {
        "kernel.perf_event_paranoid" = -1;
        # enable perf from reading kernel ptrs
        "kernel.kptr_restrict" = 0;
        # Protect against tcp time-wait assassination hazards, drop RST packets for sockets in the time-wait state.
        "net.ipv4.tcp_rfc1337" = 1;
        # block source-routed packets
        "net.ipv4.conf.default.accept_source_route" = 0;
        # reverse path filtering
        "net.ipv4.conf.default.rp_filter" = 1;
        "net.ipv4.conf.all.rp_filter" = 1;
        # disable ICMP redirect sending
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        # TCP syncookies
        "net.ipv4.tcp_syncookies" = 1;
        # BBR for tcp
        "net.core.default_qdisc" = "cake";
        "net.ipv4.tcp_congestion_control" = "bbr";
        # MTU probing
        "net.ipv4.tcp_mtu_probing" = 1;
        # TCP fast open
        "net.ipv4.tcp_fastopen" = 3;
      };
      supportedFilesystems = [ "ntfs" "exfat" ];
    };
    networking = {
      networkmanager.enable = true;
      wireless.userControlled.enable = true;
      firewall = {
        allowedTCPPorts = [ 22 80 443 8080 60676 ];
        allowedUDPPorts = [ 22 80 443 8080 ];
      };
    };
    time = {
      # timeZone = "Asia/Hong_Kong";
      hardwareClockInLocalTime = true;
    };

    nix = {
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
      '';
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
      };
      gc.automatic = true;
    };
    hardware = {
      sensor.iio.enable = true;
      bluetooth = {
        enable = true;
        disabledPlugins = [
          "sap"
        ];
      };
      graphics.enable = true;
      pulseaudio.enable = false;
      enableAllFirmware = true;
      opentabletdriver.enable = true;
      cpu = {
        intel.updateMicrocode = lib.mkDefault true;
        amd.updateMicrocode = lib.mkDefault true;
      };
    };
    musnix = {
      enable = true;
      rtcqs.enable = true;
      soundcardPciId = "00:1f.3";
    };
    # Select internationalisation properties.
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_TIME = "en_HK.UTF-8";
        LC_MEASUREMENT = "en_HK.UTF-8";
      };
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = with pkgs; [ fcitx5-rime fcitx5-mozc fcitx5-gtk libsForQt5.fcitx5-qt ];
        fcitx5.plasma6Support = true;
      };
    };

    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
        noto-fonts-extra
        libertinus
        fira-math
        comic-relief
        stix-two
        (nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })
        lmodern
        comic-mono
        font-awesome
        roboto
        source-serif
      ];
      fontconfig = {
        hinting.enable = true;
        subpixel.rgba = "rgb";
        defaultFonts = {
          serif = [
            "Noto Serif"
            "Noto Serif CJK HK"
          ];
          sansSerif = [
            "Noto Sans"
            "Noto Sans CJK HK"
          ];
          monospace = [
            "DejaVuSansMono"
            "Noto Sans Mono CJK HK"
          ];
        };
      };
    };

    services = {
      automatic-timezoned.enable = true;
      dbus.enable = true;
      flatpak.enable = true;
      displayManager = {
        autoLogin = {
          enable = true;
          user = "pca006132";
        };
        sddm = {
          wayland.enable = true;
        };
      };
      desktopManager = {
        plasma6.enable = true;
      };
      xserver = {
        enable = true;
        xkb = {
          layout = "us";
          options = "eurosign:e";
        };
      };
      printing = {
        enable = true;
        # CSE printers are HP printers
        drivers = [ pkgs.hplipWithPlugin ];
      };
      # systemd early oom killer
      earlyoom = {
        enable = true;
        extraArgs = [
          "--prefer '(^|/)(java|chromium|firefox|clang|gcc|g++|rustc|openscad)'"
        ];
      };
      # nicer terminal
      kmscon.enable = true;
      # sound with pipewire
      pipewire = {
        enable = true;
        pulse.enable = true;
        jack.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        wireplumber.enable = true;
      };
      ofono.enable = true;
      blueman.enable = true;

      # automatic device mounting
      devmon.enable = true;

      # yubikey and other hardware
      pcscd.enable = true;
      udev = {
        packages = with pkgs; [
          openocd
          yubikey-personalization
          libu2f-host
        ];
        extraHwdb = ''
          ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c24f", MODE="664", GROUP="users", TAG+="uaccess"
          ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="664", GROUP="plugdev", TAG+="uaccess"
          ACTION=="add", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="1050", ENV{ID_MODEL_ID}=="0116|0111", MODE="660", GROUP="scard"
        '';
      };

      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          Macs =
            [
              "hmac-sha2-512-etm@openssh.com"
              "hmac-sha2-256-etm@openssh.com"
              "umac-128-etm@openssh.com"
              "hmac-sha2-512,hmac-sha2-256"
              "umac-128@openssh.com"
            ];
        };
      };

      thermald.enable = true;
      fstrim.enable = true;
      hdapsd.enable = true;

      # firmware update
      fwupd.enable = true;

      btrfs.autoScrub.enable = true;
      irqbalance.enable = true;
      fail2ban.enable = true;

      tailscale.enable = true;
    };

    systemd.services = {
      # wait online is really slow and not really needed
      NetworkManager-wait-online.enable = false;
    };

    programs = {
      dconf.enable = true;
      zsh.enable = true;
      mosh.enable = true;
      xwayland.enable = true;
      adb.enable = true;
      steam.enable = true;
    };

    users.groups = {
      plugdev.members = [ "pca006132" ];
      vboxusers.members = [ "pca006132" ];
      adbusers.members = [ "pca006132" ];
      scad.members = [ "pca006132" ];
    };
    users.users = {
      pca006132 = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "uucp"
          "audio"
          "dialout"
          "networkmanager"
          "wireshark"
          "plugdev"
          "vboxusers"
          "video"
        ];
        openssh.authorizedKeys.keys = pkgs.lib.splitString "\n" (builtins.readFile ./pca006132.keys);
        initialPassword = "123456";
        shell = pkgs.zsh;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        git
        libsForQt5.qt5.qtwayland
      ];
      sessionVariables = with lib; {
        NIX_PROFILES =
          "${concatStringsSep " " (reverseList config.environment.profiles)}";
        VMLINUX = "${config.boot.kernelPackages.kernel.dev}/vmlinux";
      };
    };

    qt.platformTheme = "kde";

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        # enableNvidia = true;
      };
      # virtualbox.host = {
      #   enable = true;
      #   enableExtensionPack = true;
      # };
    };

    # performance related settings
    zramSwap.enable = true;
  };
}
