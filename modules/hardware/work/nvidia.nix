#
# NVIDIA drivers so that the laptop video card can get offloaded to specific applications.
# Either start the desktop or packages using nvidia-offload.
# For example $ nvidia-offload kdenlive
# Currently only used with work laptop using NVIDIA GTX 1050
#
{
  config,
  lib,
  pkgs,
  ...
}: let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';

  # Nvidia fix
  master = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/master.tar.gz";
  }) {config = removeAttrs config.nixpkgs.config ["packageOverrides"];};
in {
  environment = {
    systemPackages = [
      nvidia-offload
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
    ];
    sessionVariables.NIXOS_OZONE_WL = "1"; # Fix for electron apps with wayland
    # Wayland
    variables = {
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
  };
  services.xserver.videoDrivers = [
    "nvidia"
    "nvidiaLegacy470"
    "modesetting"
  ];
  # services.xserver.videoDrivers = [ "nvidiaLegacy470" ];
  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; ["nvidia-vaapi-driver"];
    };
    nvidia = {
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      # package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
      # package = pkgs.linuxKernel.packages.linux_xanmod_stable.nvidia_x11_legacy470;
      # package = pkgs.linuxKernel.packages.linux_xanmod_stable.nvidia_x11_stable_open;
      package = pkgs.linuxKernel.packages.linux_zen.nvidia_x11;

      # open = true; # opensource
      nvidiaSettings = true;
      nvidiaPersistenced = true;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        # reverseSync.enable = true;
        sync.enable = true; # will be always on and used for all rendering
      };
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      # forceFullCompositionPipeline = true;
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

  # Fix nvidia
  nixpkgs.config.packageOverrides = pkgs: {
    nvidia-vaapi-driver = master.nvidia-vaapi-driver;
  };
  #boot.kernelParams = [ "modules_blacklist=i915" ];
}
