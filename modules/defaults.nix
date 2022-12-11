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
      };
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
      cpu = {
        intel.updateMicrocode = true;
        amd.updateMicrocode = true;
      };
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
          # a lot of things are broken in wayland...
          wayland = false;
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
      xwayland.enable = services.xserver.displayManager.gdm.wayland;
    };

    users.users.pca006132 = {
      isNormalUser = true;
      extraGroups = [ "wheel" "uucp" "audio" "dialout" "networkmanager" "wireshark" ];
      openssh.authorizedKeys.keys = pkgs.lib.splitString "\n" (builtins.readFile ./pca006132.keys);
      initialPassword = "123456";
      shell = pkgs.zsh;
    };

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
