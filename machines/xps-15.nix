{ config, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a00f2d57-2d57-4528-809c-e9e2d9cb99f5";
    fsType = "btrfs";
    options = [ "compress=zstd" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/483A-A53B";
    fsType = "vfat";
  };

  networking.hostName = "pca-xps15";

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      luks.devices."cryptroot".device = "/dev/disk/by-uuid/cd3d1b5e-64f2-489d-bfca-a825d5d22b0c";
    };
    kernelModules = [ "kvm-intel" "turbostat" ];
    kernelParams = [
      "i915.enable_psr=0"
      "i915.enable_fbc=1"
      "i915.enable_guc=3"
      "i915.fastboot=1"
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_OpenRmEnableUnsupportedGpus=1"
      "ibt=off"

      # uncomment if we need cores for testing...
      # "nohz_full=19"
      # "isolcpus=19"
    ];
    extraModprobeConfig = ''
      options i915 force_probe=46a6
      options iwlwifi power_save=1 
    '';
  };

  nvidia-quirks = {
    enable = true;
    enablePrimeOffload = true;
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };

  laptop-powman.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
