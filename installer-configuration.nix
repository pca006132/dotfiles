{ installConfigurationPath ? ./default-install.nix }:

{ config, pkgs, lib, modulesPath, ... }:

let
  installConfiguration = import "${pkgs.path}/nixos" {
    configuration = import installConfigurationPath;
  };
  installBuild = installConfiguration.config.system.build;
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/profiles/installation-device.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
    "${modulesPath}/installer/tools/tools.nix"
  ];

  nixpkgs.config.allowUnfree = true;
  boot.initrd.kernelModules = [ "wl" ];
  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  system.stateVersion = "22.11";

  environment.systemPackages = with pkgs; [ git ];

  system.nixos-generate-config.configuration = builtins.readFile installConfigurationPath;

  systemd.services.sshd.enable = true;

  isoImage.compressImage = false;
  isoImage.isoBaseName = "nixos-offline-installer";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";
  isoImage.storeContents = [ installConfiguration.system ];
  isoImage.includeSystemBuildDependencies = false;
  isoImage.squashfsCompression = "zstd -Xcompression-level 10";
  nix.settings.experimental-features = [ "nix-command" ];

  systemd.services.installer = {
    description = "Unattended NixOS installer";
    wantedBy = [ "multi-user.target" ];
    after = [ "getty.target" "nscd.service" ];
    conflicts = [ "getty@tty1.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      StandardInput = "tty-force";
      StandardOutput = "inherit";
      StandardError = "inherit";
      TTYReset = "yes";
      TTYVHangup = "yes";
    };
    path = [ "/run/current-system/sw" ];
    environment = config.nix.envVars // {
      inherit (config.environment.sessionVariables) NIX_PATH;
      HOME = "/root";
    };
    script = ''
      set -euxo pipefail
      # If the partitions exist already as-is, parted might error out
      # telling that it can't communicate changes to the kernel...
      wipefs -fa /dev/sda
      # These are the exact steps from
      # https://nixos.org/nixos/manual/index.html#sec-installation-summary
      # needed to add a few -s (parted) and -F (mkfs.ext4) etc. flags to
      # supress prompts
      parted -s /dev/sda -- mklabel gpt
      parted -s /dev/sda -- mkpart primary 512MiB 100%
      parted -s /dev/sda -- mkpart ESP fat32 1MiB 512MiB
      parted -s /dev/sda -- set 2 boot on
      mkfs.ext4 -F -L nixos /dev/sda1
      echo "y" | mkfs.fat -F 32 -n boot /dev/sda2
      # wait until labels appear
      until [ -e /dev/disk/by-label/nixos ] && [ -e /dev/disk/by-label/boot ]; do sleep 2; done
      mount /dev/disk/by-label/nixos /mnt
      mkdir -p /mnt/boot
      mount /dev/disk/by-label/boot /mnt/boot
      nixos-generate-config --root /mnt
      mkdir /mnt/etc/nixos/modules
      cp ${./modules/pca006132.keys} /mnt/etc/nixos/modules/pca006132.keys
      cp ${./modules/defaults.nix} /mnt/etc/nixos/modules/defaults.nix
      cp ${./modules/laptop-powermanagement.nix} /mnt/etc/nixos/modules/laptop-powermanagement.nix
      cp ${./modules/nvidia.nix} /mnt/etc/nixos/modules/nvidia.nix
      cp ${./default-install.nix} /mnt/etc/nixos/configuration.nix

      # nixos-install will run "nix build --store /mnt ..." which won't be able
      # to see what we have in the installer nix store, so copy everything
      # needed over.
      nix build -f '<nixpkgs/nixos>' system -I "nixos-config=/mnt/etc/nixos/configuration.nix" -o /out
      nix copy --no-check-sigs --to local?root=/mnt /out
      ${installBuild.nixos-install}/bin/nixos-install --no-root-passwd --no-channel-copy
      reboot
    '';
  };
}
