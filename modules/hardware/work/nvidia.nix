#
# NVIDIA drivers so that the laptop video card can get offloaded to specific applications.
# Either start the desktop or packages using nvidia-offload.
# For example $ nvidia-offload kdenlive
# Currently only used with work laptop using NVIDIA MX330
#

{ config, lib, pkgs, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  environment = {
    systemPackages = [
      nvidia-offload
    ];
    sessionVariables.NIXOS_OZONE_WL = "1"; # Fix for electron apps with wayland
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  # services.xserver.videoDrivers = [ "nvidiaLegacy470" ];
  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
    nvidia = {
      #package = config.boot.kernelPackages.nvidiaPackages.beta;
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
      #open = true;
      nvidiaPersistenced = true;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        reverseSync.enable = true;
        # sync.enable = true; # will be always on and used for all rendering
      };
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
    };
  };

  ## booting with an external display
  #specialisation = {
  #  external-display.configuration = {
  #    system.nixos.tags = [ "external-display" ];
  #    hardware.nvidia.prime.offload.enable = lib.mkForce false;
  #    hardware.nvidia.powerManagement.enable = lib.mkForce false;
  #  };
  #};

  #boot.kernelParams = [ "modules_blacklist=i915" ];
}
