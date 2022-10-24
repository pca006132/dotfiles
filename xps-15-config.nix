# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_ONLY
    exec "$@"
  '';
  pkgs-unstable = import <nixpkgs-unstable> { config.allowUnfree = true; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  fileSystems."/".options = [ "compress=zstd" ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";
  time.hardwareClockInLocalTime = true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    trustedUsers = [
      "root"
      "pca006132"
    ];
  };

  boot.kernelParams = [ "i915.enable_psr=0" "nvidia_drm.modeset=1" "quiet" ];
  boot.extraModprobeConfig = ''
    options i915 force_probe=46a6
    options nvidia NVreg_PreserveVideoMemoryAllocations=1
  '';
  boot.kernelPackages = pkgs-unstable.linuxPackages_xanmod_latest;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [ rime ];
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
  ];
  fonts.fontconfig.hinting.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.prime = {
    offload.enable = true;
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;
  services.xserver.screenSection = ''
    Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
  '';
  services.xserver.serverLayoutSection = ''
    Inactive "Device-nvidia[0]"
    Option "AllowNVIDIAGPUScreens"
  '';
  services.xserver.displayManager.setupCommands = ''
    xrandr --setprovideroutputsource Intel modesetting
  '';

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.earlyoom.enable = true;
  services.logind.extraConfig = ''
    RuntimeDirectorySize=50%
  '';
  services.kmscon.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };
  services.ofono.enable = true;

  hardware.bluetooth = {
    enable = true;
    hsphfpd.enable = true;
    disabledPlugins = [
      "sap"
    ];
  };
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;

      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";

      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "auto";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "schedutil";

      NATACPI_ENABLE = 1;
      TPACPI_ENABLE = 1;
      TPSMAPI_ENABLE = 1;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pca006132 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "uucp" "audio" "dialout" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTMW8zyxAwl7B4Ix9mlA5us60HegzDrZ0bCqTipbmxW root@localhost"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrC43AF/aHv9NHormDMw18m/iE3luNc4CIwgPgTClly4b9yRyQGhm4mKkKix07fP9SfdyvUPPrYhwoHhf0zGkfFNE26FIG2Bul9UkZVP3ygnIXHD7sKUJP7Ra4UID6Naf3Mr2Dckh7rAiw8WN2QB+oO2tni3PyceEOdu8OoEsmSu8qusJFVhnaoYJyQflgGl3bFUZkhaf1JKQmv9C92sfKQkrfSNb2dNrc3Oe1uP5VokhLhjsOoDWyJ45a7ru6lr4/Co5sF9xX59cOOBU+ktiOakDI8NLI5AO7R0dCKLW55wUnml5boeCV45p1MPXVEznX8IM6kRgOhVx3fnd0TqV5M8xeY0dk7aTWTFSkIz82xHhKFbce5xx+9MFrlvUgHYVpbIUQTq6HS6cLZEeWHDLuUqbRFB4J7UfieiRZfxWw74Tgyq+HlvlNg/cVn0nhouq6+sY6QI9MGbwbEnjkD5KbSUHUCSeLgNc8pb0RxLkAqPGh8QkYrb6Nudl8HjWfIuZFGrRhcGBySt/oaYUDrUg5VNA98FjQL2QfKRVepvpGgUEGW6eZK9IrYz1Ct30Sb65QujUMRuDnWq1CeulAXCZQHc32wOrHRkMEUdhfOgNojZRTGduPayHXoDq7XB249D2VjH/vEuiLfWNLr+rabGyMUPpQaDypeBgOsUTbceKbDw=="
    ];
    shell = "/home/pca006132/.nix-profile/bin/zsh";
  };

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.devmon.enable = true;
  services.pcscd.enable = true;

  services.udev.packages = with pkgs; [
    openocd
    yubikey-personalization
    libu2f-host
  ];

  environment.shells = [ "/run/current-system/sw/bin/zsh" ];
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
    nodejs
    gparted
    git
    binutils
    htop
    unzip
    zip
    p7zip
    ntfs3g
    udevil
    yubico-piv-tool
    pinentry-curses
    pinentry-qt

    arc-kde-theme
    gnome.adwaita-icon-theme
    firefox-bin

    pkgs-unstable.zoom-us
    nvidia-offload
    steam
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

