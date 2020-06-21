# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Bootloader settings
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    devices = ["nodev"];
    version = 2;
    useOSProber = true;
    enable = true;
    efiSupport = true;
    #efiInstallAsRemovable = true;
  };

  # Networking settings
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;

  # Configure network proxy if necessary
  networking.networkmanager.enable = true;
  
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [ rime ];
  };

  fonts.fonts = [ 
    pkgs.noto-fonts pkgs.noto-fonts-cjk pkgs.noto-fonts-emoji pkgs.noto-fonts-extra 
  ];

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";
  time.hardwareClockInLocalTime = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    wget vim ripgrep fd curl aria bat ydiff
    usbutils pciutils tmux minicom kitty
    fd nodejs firefox-bin gparted thunderbird
    git binutils htop unzip zip p7zip ntfs3g 
    udevil nix-index
    # XFCE stuff
    xfce.xfce4-battery-plugin xfce.xfce4-weather-plugin
    # Yubikey stuff
    gnupg pinentry-curses pinentry-qt paperkey
  ];


  programs.wireshark.enable = true;
  programs.command-not-found.enable = false;
  programs.zsh.interactiveShellInit = ''
    source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
  '';

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt]; 
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
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
  };

  # Nvidia driver
  hardware.nvidia.optimus_prime.enable = true;
  hardware.nvidia.optimus_prime.allowExternalGpu = true;
  hardware.nvidia.optimus_prime.intelBusId = "PCI:0:2:0";
  hardware.nvidia.optimus_prime.nvidiaBusId = "PCI:1:0:0";
  services.xserver.videoDrivers = ["nvidia" "nvidiaLegacy390"];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users.pca = {
    isNormalUser = true;
    extraGroups = [ "wheel" "uucp" "audio" "dialout" "plugdev" ]; 
  };

  # udev settings
  services.udev.packages = [ pkgs.openocd pkgs.yubikey-personalization ];
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
  '';
  services.pcscd.enable = true;
  hardware.u2f.enable = true;
  programs.ssh.extraConfig = 
    ''
    PKCS11Provider "${pkgs.opensc}/lib/opensc-pkcs11.so"
    '';
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

  nix.binaryCaches = [
    "https://cache.nixos.org"
  ];

  # enable auto-mounting
  services.devmon.enable = true; 
}

