# largely copied from
# https://github.com/tfc/nixos-offline-installer
{ self, buildDerivation, flakeInputs, config, pkgs, lib, modulesPath, ... }:

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
  nixpkgs.hostPlatform = "x86_64-linux";

  environment.systemPackages = with pkgs; [ git ];

  systemd.services.sshd.enable = true;

  isoImage.compressImage = false;
  isoImage.isoBaseName = "nixos-offline-installer";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";
  isoImage.storeContents = [
    buildDerivation
  ] ++ flakeInputs;
  isoImage.includeSystemBuildDependencies = true;
  # actually a lot faster than xz while not being very large
  isoImage.squashfsCompression = "zstd -Xcompression-level 1";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
      # set -euxo pipefail
      # If the partitions exist already as-is, parted might error out
      # telling that it can't communicate changes to the kernel...
      wipefs -fa /dev/sda
      parted -s /dev/sda -- mklabel gpt
      parted -s /dev/sda -- mkpart primary 1GiB -16GiB
      parted -s /dev/sda -- mkpart ESP fat32 1MiB 1GiB
      parted -s /dev/sda -- mkpart primary linux-swap -16GiB 100%
      parted -s /dev/sda -- set 2 boot on
      mkswap -L swap /dev/sda3
      swapon /dev/sda3
      mkfs.ext4 -F -L nixos /dev/sda1
      echo "y" | mkfs.fat -F 32 -n boot /dev/sda2
      # wait until labels appear
      until [ -e /dev/disk/by-label/nixos ] && [ -e /dev/disk/by-label/boot ]; do sleep 2; done
      mount /dev/disk/by-label/nixos /mnt
      mkdir -p /mnt/boot
      mount /dev/disk/by-label/boot /mnt/boot
      mkdir -p /mnt/etc/nixos
      cp -r ${self}/* /mnt/etc/nixos
      nixos-generate-config --root /mnt

      nix build /mnt/etc/nixos#nixosConfigurations.barebone.config.system.build.toplevel --offline -o /out
      nixos-install -v --system /out --no-root-passwd --no-channel-copy
      reboot
    '';
  };
}
