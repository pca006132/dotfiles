{ pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-uuid/d99e4faa-55fa-4f92-a329-77f846b49dd2";
        fsType = "btrfs";
        options = [ "compress=zstd" ];
      };
    "/nix" = {
      device = "/dev/disk/by-uuid/3ba40d0b-a2cd-4765-b5b1-5585e499cc57";
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/DDFE-7DB8";
      fsType = "vfat";
    };
  };

  networking.hostName = "pca-workstation";

  boot = {
    kernel.sysctl = {
      # Disable proactive compaction because it introduces jitter
      "vm.compaction_proactiveness" = 0;
      # Reduce the maximum page lock acquisition latency while retaining adequate throughput
      "vm.page_lock_unfairness" = 1;
      "vm.vfs_cache_pressure" = 50;
    };
  };

  nvidia-quirks = { enable = true; };

  system.stateVersion = "22.11";
}
