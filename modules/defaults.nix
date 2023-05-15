{ config, lib, pkgs, ... }:
{
  config = rec {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "x86_64-linux";
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
      kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_latest;
      kernel.sysctl."kernel.perf_event_paranoid" = -1;
      supportedFilesystems = [ "ntfs" "exfat" ];
    };
    networking = {
      networkmanager.enable = true;
      wireless.userControlled.enable = true;
      firewall.allowedTCPPorts = [ 3389 ];
      firewall.allowedUDPPorts = [ 3389 ];
    };
    time = {
      timeZone = "Asia/Hong_Kong";
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
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
      pulseaudio.enable = false;
      enableAllFirmware = true;
      opentabletdriver.enable = true;
      cpu = {
        intel.updateMicrocode = lib.mkDefault true;
        amd.updateMicrocode = lib.mkDefault true;
      };
    };
    # Select internationalisation properties.
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_TIME = "en_HK.UTF-8";
        LC_MEASUREMENT = "en_HK.UTF-8";
      };
      inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = with pkgs; [ fcitx5-rime fcitx5-gtk libsForQt5.fcitx5-qt];
      };
    };

    environment.sessionVariables = with lib; {
      NIX_PROFILES =
        "${concatStringsSep " " (reverseList config.environment.profiles)}";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
    };

    fonts = {
      fonts = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-extra
      ];
      fontconfig.hinting.enable = true;
    };

    services = {
      dbus.enable = true;
      flatpak.enable = true;
      gnome.gnome-remote-desktop.enable = true;
      xserver = {
        enable = true;
        displayManager = {
          autoLogin = {
            enable = true;
            user = "pca006132";
          };
          defaultSession = "plasmawayland";
          # sddm is somehow buggy...
          gdm.enable = true;
        };
        desktopManager = {
          gnome.enable = false;
          plasma5.enable = true;
          xterm.enable = false;
        };
        layout = "us";
        # Configure keymap in X11
        xkbOptions = "eurosign:e";
      };
      printing = {
        enable = true;
        # CSE printers are HP printers
        drivers = [ pkgs.hplipWithPlugin ];
      };
      # systemd early oom killer
      earlyoom.enable = true;
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
          ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="664", GROUP="plugdev", TAG+="uaccess"
        '';
      };

      openssh = {
        enable = true;
        permitRootLogin = "no";
        passwordAuthentication = false;
      };

      thermald.enable = true;
      fstrim.enable = true;
      hdapsd.enable = true;

      # firmware update
      fwupd.enable = true;
    };

    # wait online is really slow and not really needed
    systemd.services.NetworkManager-wait-online.enable = false;

    programs = {
      bcc.enable = true;
      dconf.enable = true;
    };

    users.users.pca006132 = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "uucp"
        "audio"
        "dialout"
        "networkmanager"
        "wireshark"
        "plugdev"
      ];
      openssh.authorizedKeys.keys = pkgs.lib.splitString "\n" (builtins.readFile ./pca006132.keys);
      initialPassword = "123456";
      shell = pkgs.zsh;
    };

    environment.systemPackages = with pkgs; [ git ];

    qt5.platformTheme = "kde";

    # performance related settings
    zramSwap.enable = true;
  };
}
