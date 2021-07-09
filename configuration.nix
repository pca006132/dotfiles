# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  unstable = import <nixpkgs> {
    config = { allowUnfree = true; };
  };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Bootloader settings
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    devices = [ "nodev" ];
    version = 2;
    useOSProber = true;
    enable = true;
    efiSupport = true;
    #efiInstallAsRemovable = true;
  };

  # Networking settings
  networking = {
    useDHCP = false;
    interfaces = {
      enp2s0.useDHCP = true;
      wlo1.useDHCP = true;
    };
    dhcpcd.persistent = true;
    networkmanager = {
      enable = true;
      dhcp = "dhclient";
      appendNameservers = [ "8.8.8.8" "8.8.4.4" ];
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [ rime ];
  };

  fonts.fonts = [
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk
    pkgs.noto-fonts-emoji
    pkgs.noto-fonts-extra
    pkgs.symbola
  ];

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";
  time.hardwareClockInLocalTime = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    wget
    vim
    ripgrep
    fd
    curl
    aria
    bat
    ydiff
    usbutils
    pciutils
    tmux
    minicom
    fd
    nodejs
    firefox-bin
    gparted
    thunderbird
    git
    binutils
    htop
    unzip
    zip
    p7zip
    ntfs3g
    udevil
    # KDE
    arc-kde-theme
    # Smart card
    yubico-piv-tool
    pinentry-curses
    pinentry-qt
    paperkey
    unstable.zoom-us
  ];

  programs.wireshark.enable = true;

  environment.shells = [ pkgs.bashInteractive pkgs.zsh ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.earlyoom.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    zeroconf = {
      discovery.enable = true;
      publish.enable = true;
    };
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  services.xserver = {
    desktopManager = {
      plasma5.enable = true;
    };
    displayManager = {
      sddm.enable = true;
    };
  };

  hardware.enableAllFirmware = true;

  # Nvidia driver
  hardware.nvidia.prime.sync.enable = true;
  hardware.nvidia.prime.sync.allowExternalGpu = true;
  hardware.nvidia.prime.intelBusId = "PCI:0:2:0";
  hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
  services.xserver.videoDrivers = [ "nvidiaLegacy430" "nvidia" ];

  systemd.services.nvidia-control-devices = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users.pca = {
    isNormalUser = true;
    extraGroups = [ "wheel" "uucp" "audio" "dialout" "plugdev" "wireshark" ];
  };

  # udev settings
  services.udev.packages = [ pkgs.openocd pkgs.yubikey-personalization pkgs.libu2f-host ];
  services.udev.extraRules = ''
    # leaf maple
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1eaf", ATTRS{idProduct}=="0003", MODE="0660", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1eaf", ATTRS{idProduct}=="0004", MODE="0660", GROUP="plugdev"
    # glasgow
    SUBSYSTEM=="usb", ATTRS{idVendor}=="20b7", ATTRS{idProduct}=="9db1", MODE="0660", GROUP="plugdev"
    # hackrf
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6089", MODE="0660", GROUP="plugdev"
    # bladerf
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2cf0", ATTRS{idProduct}=="5250", MODE="0660", GROUP="plugdev"
    # personal measurement device
    SUBSYSTEM=="usb", ATTRS{idVendor}=="09db", ATTRS{idProduct}=="007a", MODE="0660", GROUP="plugdev"
    # logic analyzer
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0925", ATTRS{idProduct}=="3881", MODE="0660", GROUP="plugdev"
    # Segger JLink
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0101", MODE="0660", GROUP="plugdev"
  '';

  services.pcscd.enable = true;
  programs.ssh.extraConfig =
    ''
      PKCS11Provider "${pkgs.opensc}/lib/opensc-pkcs11.so"
    '';

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  # enable auto-mounting
  services.devmon.enable = true;

  networking.nameservers = [ "8.8.8.8" ];

  # power management
  services.tlp = {
    enable = true;
    extraConfig = ''
        START_CHARGE_THRESH_BAT0=75
        STOP_CHARGE_THRESH_BAT0=80

        CPU_SCALING_GOVERNOR_ON_AC=schedutil
        CPU_SCALING_GOVERNOR_ON_BAT=schedutil

        # Enable audio power saving for Intel HDA, AC97 devices (timeout in secs).
        # A value of 0 disables, >=1 enables power saving (recommended: 1).
        # Default: 0 (AC), 1 (BAT)
        SOUND_POWER_SAVE_ON_AC=0
        SOUND_POWER_SAVE_ON_BAT=1

        # Runtime Power Management for PCI(e) bus devices: on=disable, auto=enable.
        # Default: on (AC), auto (BAT)
        RUNTIME_PM_ON_AC=on
        RUNTIME_PM_ON_BAT=auto

        RADEON_DPM_STATE_ON_AC=performance
        RADEON_DPM_STATE_ON_BAT=auto

        CPU_ENERGY_PERF_POLICY_ON_AC=performance
        CPU_ENERGY_PERF_POLICY_ON_BAT=balanced_power

        # Battery feature drivers: 0=disable, 1=enable
        # Default: 1 (all)
        NATACPI_ENABLE=1
        TPACPI_ENABLE=1
        TPSMAPI_ENABLE=1
    '';
  };
}
