# PCA's Configuration Files
This repo contains configuration for my machines using NixOS and home manager.

Usage (normally you cannot use them directly)
```bash
sudo nixos-rebuild switch --flake '.#MACHINE'
```

## Experimental Offline Installer
I'm trying to make an offline installer with flakes by modifying
[tfc/nixos-offline-installer](https://github.com/tfc/nixos-offline-installer).
Currently it can boot on a QEMU VM but requires hardcoding the hardware
configuration. Building flakes without internet doesn't seem to work (it will
report error even though in principle it doesn't have to trigger a rebuild).

```bash
nix build
qemu-img create -f qcow2 /tmp/qemu-mydisk.img 30G
qemu-system-x86_64 -enable-kvm -boot d -hda /tmp/qemu-mydisk.img -m 2000 -bios $(nix-build '<nixpkgs>' -A pkgs.OVMF.fd --no-out-link)/FV/OVMF.fd -net none -cdrom result/iso/*.iso
```

Note that the default one here is pretty large because it contains my whole
configuration.
