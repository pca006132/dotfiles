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

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    devices = ["nodev"];
    version = 2;
    useOSProber = true;
    enable = true;
    efiSupport = true;
    #efiInstallAsRemovable = true;
  };

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;

  # Configure network proxy if necessary
  networking.networkmanager.enable = true;
  
  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";
  time.hardwareClockInLocalTime = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim ripgrep fd curl aria gcc clang rustc cargo bat emacs
    usbutils pciutils tmux gdb minicom kitty
    fd nodejs firefox-bin gparted thunderbird
    git binutils htop unzip zip p7zip #texlive.combined.scheme-full #tldr
    ntfs3g #(python3.withPackages(ps: with ps; [ numpy scipy matplotlib regex ]))
    gnome3.gnome-tweaks gnome3.gnome-shell-extensions
    udevil
  ];

  nixpkgs.config.firefox.enableGnomeExtensions = true;
  services.gnome3.chrome-gnome-shell.enable = true;

  programs.wireshark.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt]; 
  };
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [ rime ];
  };
  fonts.fonts = [ 
    pkgs.noto-fonts pkgs.noto-fonts-cjk pkgs.noto-fonts-emoji pkgs.noto-fonts-extra 
  ];
  
  users.defaultUserShell = pkgs.zsh;

  # Enable the KDE Desktop Environment.
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pca = {
    isNormalUser = true;
    extraGroups = [ "wheel" "uucp" "audio" "dialout" "plugdev" ]; # Enable ‘sudo’ for the user.
  };

  services.udev.packages = [ pkgs.openocd ];
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

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  services.devmon.enable = true; 
}
