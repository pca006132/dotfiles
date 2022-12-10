# largely copied from
# https://github.com/tfc/nixos-offline-installer
{ self, systemBuild, config, pkgs, lib, modulesPath, ... }:

let
  installBuild = systemBuild.config.system.build.toplevel;
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
  nixpkgs.hostPlatform = "x86_64-linux";

  environment.systemPackages = with pkgs; [ git ];

  systemd.services.sshd.enable = true;

  isoImage.compressImage = false;
  isoImage.isoBaseName = "nixos-offline-installer";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";
  isoImage.storeContents = [ installBuild ];
  isoImage.includeSystemBuildDependencies = false;
  # actually a lot faster than xz while not being very large
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";
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
      set -euxo pipefail
      # If the partitions exist already as-is, parted might error out
      # telling that it can't communicate changes to the kernel...
      wipefs -fa /dev/sda
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

      # currently it only works with predefined hardware-configuration
      # nixos-generate-config --root /mnt
      nix copy --no-check-sigs --to local?root=/mnt ${installBuild}
      system=$(readlink -f ${installBuild})
      nix-env --store /mnt -p /mnt/nix/var/nix/profiles/system --set "$system"
      ln -sfn /proc/mounts /mnt/etc/mtab
      mkdir -m 0755 -p "/mnt/etc"
      touch "/mnt/etc/NIXOS"
      NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root /mnt -- /run/current-system/bin/switch-to-configuration boot
      reboot
    '';
  };
}
