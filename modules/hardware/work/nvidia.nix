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
      libva
      libva-utils
      glxinfo
    ];
    sessionVariables.NIXOS_OZONE_WL = "1"; # Fix for electron apps with wayland
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    opengl.enable = true;
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
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

  #boot.kernelParams = [ "modules_blacklist=i915" ];
}
