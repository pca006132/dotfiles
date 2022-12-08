# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  pkgs-unstable = import <nixpkgs-unstable> { config.allowUnfree = true; };
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/nvidia.nix
      ./modules/laptop-powermanagement.nix
      ./modules/defaults.nix
    ];

  fileSystems."/".options = [ "compress=zstd" ];

  networking.hostName = "pca-xps15";

  boot = {
    kernelModules = [ "kvm-intel" "dell-smm-hwmon" "turbostat" ];
    kernelParams = [
      "i915.enable_psr=0"
      "i915.enable_fbc=1"
      "i915.fastboot=1"
    ];
    extraModprobeConfig = ''
      options i915 force_probe=46a6
    '';
    kernelPackages = pkgs-unstable.linuxPackages_xanmod_latest;
  };

  nvidia-quirks = {
    enable = true;
    enablePrimeOffload = true;
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };

  laptop-powman.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
