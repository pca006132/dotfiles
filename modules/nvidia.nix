{ config, lib, pkgs, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_ONLY
    exec "$@"
  '';
  cfg = config.nvidia-quirks;
in
with lib; {
  options.nvidia-quirks = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable nvidia quirks
      '';
    };
    enablePrimeOffload = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable nvidia prime offload quirks
      '';
    };
    nvidiaBusId = mkOption {
      type = types.str;
      description = ''
        PCI ID of your Nvidia GPU
        Only needed if you use prime offload
      '';
    };
    intelBusId = mkOption {
      type = types.str;
      description = ''
        PCI ID of your Intel CPU
        Only needed if you use prime offload
      '';
    };
  };
  config = mkIf cfg.enable {
    boot = {
      kernelParams = [ "nvidia_drm.modeset=1" "nvidia_drm.fbdev=1" ];
      extraModprobeConfig = ''
        options nvidia NVreg_PreserveVideoMemoryAllocations=1
      '';
    };
    services.xserver = mkIf config.services.xserver.enable {
      videoDrivers = [ "nvidia" ];
      screenSection = mkIf cfg.enablePrimeOffload ''
        Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        Option         "AllowIndirectGLXProtocol" "off"
        Option         "TripleBuffer" "on"
      '';
      serverLayoutSection = mkIf cfg.enablePrimeOffload ''
        Inactive "Device-nvidia[0]"
        Option "AllowNVIDIAGPUScreens"
      '';
      displayManager.setupCommands = mkIf cfg.enablePrimeOffload ''
        xrandr --setprovideroutputsource Intel modesetting
      '';
    };
    hardware = {
      nvidia = {
        modesetting.enable = true;
        nvidiaPersistenced = false;
        powerManagement = {
          enable = true;
          finegrained = cfg.enablePrimeOffload;
        };
        forceFullCompositionPipeline = true;
        prime = mkIf cfg.enablePrimeOffload {
          offload.enable = true;
          nvidiaBusId = cfg.nvidiaBusId;
          intelBusId = cfg.intelBusId;
        };
      };
      opengl = mkIf config.hardware.opengl.enable {
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
          nvidia-vaapi-driver
        ];
      };
    };
    environment.systemPackages = mkIf cfg.enablePrimeOffload [ nvidia-offload ];
  };
}
