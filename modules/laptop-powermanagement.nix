{ config, lib, pkgs, ... }:
let
  cfg = config.laptop-powman;
in
with lib; {
  options.laptop-powman = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable laptop power management settings
      '';
    };
  };
  config = {
    # use tlp instead of power-profiles-daemon
    services = mkIf cfg.enable {
      power-profiles-daemon.enable = false;
      tlp = {
        enable = true;
        settings = {
          SOUND_POWER_SAVE_ON_AC = 0;
          SOUND_POWER_SAVE_ON_BAT = 1;

          CPU_DRIVER_OPMODE_ON_AC = "guided";
          CPU_DRIVER_OPMODE_ON_BAT = "active";
          CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "powersave";

          RUNTIME_PM_ENABLE = "01:00.0";
        };
      };
    };
    powerManagement.cpuFreqGovernor = mkIf (!cfg.enable) "performance";
  };
}
