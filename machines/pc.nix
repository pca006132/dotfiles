{ config, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-uuid/f8c9e8ff-8933-40fa-9a66-1af4805f2e0e";
        fsType = "btrfs";
        options = [ "compress=zstd" "noatime" ];
      };
    "/home" = {
      device = "/dev/disk/by-uuid/4fb62dfb-9ef6-4402-9bcc-e452b0129cc7";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1BDC-F4C1";
      fsType = "vfat";
    };
    "/mediafiles" = {
      device = "/dev/disk/by-uuid/46136e37-e293-4b66-a705-e1b9575ff8e2";
      fsType = "btrfs";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/5418b10c-139b-4216-8443-052844fc34e3"; }];

  networking.hostName = "pca-pc";

  boot = {
    initrd = {
      luks.devices = {
        "cryptroot".device = "/dev/disk/by-uuid/2b41c705-7971-4f06-97fc-1604efe5586e";
        "crypthome".device = "/dev/disk/by-uuid/ee7c1d38-43e2-4b75-83d7-f32aa668e8d9";
      };
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
    };
    kernelModules = [ "kvm-intel" "turbostat" ];
    kernelPatches = [{
      name = "e1000e-bypass-checksum";
      patch = ./e1000e.diff;
    }];
    # for testing realtime application
    kernelParams = [ "nohz_full=19" "isolcpus=19" ];
    kernel.sysctl = {
      # Disable proactive compaction because it introduces jitter
      "vm.compaction_proactiveness" = 0;
      "vm.swappiness" = 10;
      # Reduce the maximum page lock acquisition latency while retaining adequate throughput
      "vm.page_lock_unfairness" = 1;
      "vm.vfs_cache_pressure" = 50;
    };
  };

  nvidia-quirks = { enable = true; };

  # systemd.services = {
  #   duckdns = {
  #     startAt = "*-*-* *:0/5:00";
  #     wantedBy = [ "sshd.service" ];
  #     after = [ "network.target" ];
  #     description = "Update duckdns IP";
  #     path = with pkgs; [curl coreutils];
  #     serviceConfig = {
  #       User = "pca006132";
  #       ExecStart = (pkgs.writeShellScript "duckdns-update.sh" ''
  #         echo url="https://www.duckdns.org/update?domains=pca006132&token=$(cat $TOKENPATH)&ip=" | curl -k -K -
  #       '');
  #       LoadCredentialEncrypted = "duckdns-token:/home/pca006132/secrets/duckdns-token";
  #       Environment = "TOKENPATH=%d/duckdns-token";
  #       StandardOutput = "journal";
  #     };
  #   };
  # };
  #
  # security.acme = rec {
  #   acceptTerms = true;
  #   defaults.email = "cklamaq@cse.ust.hk";
  #   certs."pca006132.duckdns.org" = {
  #     domain = "pca006132.duckdns.org";
  #     # sadly cannot use LoadCredentialEncrypted here
  #     credentialsFile = "/home/pca006132/secrets/lego-secrets";
  #     dnsProvider = "duckdns";
  #   };
  # };
  #
  # services.nix-serve = {
  #   enable = true;
  #   openFirewall = true;
  #   secretKeyFile = "/home/pca006132/secrets/nix-store";
  # };

  system.stateVersion = "22.11";
}
