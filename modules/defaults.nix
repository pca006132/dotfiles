{ config, lib, pkgs, ... }:
{
  config = {
    nixpkgs.config.allowUnfree = true;
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
      kernelPackages = pkgs.linuxPackages_xanmod_latest;
      kernel.sysctl."kernel.perf_event_paranoid" = -1;
    };
    networking = {
      networkmanager.enable = true;
      wireless.userControlled.enable = true;
      # firewall.allowedTCPPorts = [ ];
      # firewall.allowedUDPPorts = [ ];
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
      }
      gc.automatic = true;
    };
    hardware = {
      sensor.iio.enable = true;
      bluetooth = {
        enable = true;
        hsphfpd.enable = true;
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
    };
    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

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
      xserver = {
        enable = true;
        # Enable the GNOME Desktop Environment.
        displayManager.gdm = {
          enable = true;
          wayland = true;
        };
        desktopManager = {
          gnome.enable = true;
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
      };
      ofono.enable = true;
      blueman.enable = true;

      # automatic device mounting
      devmon.enable = true;

      # yubikey and other hardware
      pcscd.enable = true;
      udev.packages = with pkgs; [
        openocd
        yubikey-personalization
        libu2f-host
      ];

      openssh = {
        enable = true;
        permitRootLogin = "no";
        passwordAuthentication = false;
      };

      # firmware update
      fwupd.enable = true;
    };

    programs = {
      bcc.enable = true;
      dconf.enable = true;
    };

    users.users.pca006132 = {
      isNormalUser = true;
      extraGroups = [ "wheel" "uucp" "audio" "dialout" "networkmanager" "wireshark" ];
      openssh.authorizedKeys.keys = pkgs.lib.splitString "\n" (builtins.readFile (builtins.fetchurl {
        url = "https://github.com/pca006132.keys";
        sha256 = "01kvvqdi0j0dvkc9z3cv6hajvfljv0b7vhxziz9kbddc1xwrkvar";
      }));
      shell = "/home/pca006132/.nix-profile/bin/zsh";
      initialPassword = "123456";
    };

    environment.shells = [ "/home/pca006132/.nix-profile/bin/zsh" ];
    environment.systemPackages = with pkgs; [ git ];

    # performance related settings
    zramSwap.enable = true;
    systemd.services.sshd.serviceConfig = {
      MemorySwapMax = 0;
      MemoryZswapMax = 0;
      Nice = -15;
    };
  };
}
