# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  pkgs-unstable = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz) {
    config = { allowUnfree = true; };
  }; 
  rtw89 = { pkgs, kernel }: 
  let
    stdenv = pkgs.stdenv;
    fetchFromGitHub = pkgs.fetchFromGitHub;
    modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
  in pkgs.stdenv.mkDerivation {
    pname = "rtw89";
    version = "unstable-2022-01-22";

    src = fetchFromGitHub {
      owner = "lwfinger";
      repo = "rtw89";
      rev = "72c62621c207eb4e8b68b92522fd104ebc32fa69";
      sha256 = "0xjzbm21zf3b87kgam0dn68c2dk0sqnia6c751lb5jkxwzsqxnn1";
    };

    makeFlags = [ "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

    enableParallelBuilding = true;

    installPhase = ''
      runHook preInstall
      mkdir -p ${modDestDir}
      find . -name '*.ko' -exec cp --parents {} ${modDestDir} \;
      find ${modDestDir} -name '*.ko' -exec xz -f {} \;
      runHook postInstall
    '';
  };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.pulseaudio = true;

  nix = {
    package = pkgs.nixUnstable;
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

  # Use the systemd-boot EFI boot loader.
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  boot.extraModulePackages = [
    (rtw89 {inherit pkgs; kernel = pkgs.linuxPackages_xanmod.kernel; })
  ];
  boot.loader = {
    #efi.canTouchEfiVariables = true;
    grub = {
      devices = [ "nodev" ];
      version = 2;
      useOSProber = true;
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  networking.hostName = "pca-yoga"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.wifi.powersave = true;
  networking.wireless.iwd.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";
  time.hardwareClockInLocalTime = true;

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
  fonts.fontconfig.hinting.enable = false;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
    amdvlk
  ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  programs.ssh.startAgent = false;

  # power management
  services.auto-cpufreq.enable = true;
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

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  services.earlyoom.enable = true;
  services.logind.extraConfig = ''
    RuntimeDirectorySize=50%
  '';
  services.journald.extraConfig = ''
    MaxRetentionSec=4day
  '';

  services.kmscon.enable = true;

  # Enable sound.
  sound.enable = true;
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

  hardware.enableAllFirmware = true;
  services.devmon.enable = true;
  services.pcscd.enable = true;

  services.udev.packages = with pkgs; [
    openocd
    yubikey-personalization
    libu2f-host
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users.pca006132 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "uucp" "audio" "dialout" "networkmanager" ];
  };

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
    thunderbird
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

    pkgs-unstable.zoom-us
    pkgs-unstable.firefox-bin
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

