#
#  Specific system configuration settings for desktop
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./vm
#   │       ├─ default.nix *
#   │       └─ hardware-configuration.nix
#   └─ ./modules
#       └─ ./desktop
#           └─ ./bspwm
#               └─ bspwm.nix
#

{ config, pkgs, ... }:

{
  imports = [
    # For now, if applying to other system, swap files
    ./hardware-configuration.nix # Current system hardware config @ /etc/nixos/hardware-configuration.nix
    ../../modules/desktop/bspwm/default.nix # Window Manager
  ];

  boot = {
    isContainer = false;
    # Boot options
    kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages; # zfs
    kernel.sysctl = {
      "vm.vfs_cache_pressure" = 500;
      "vm.swappiness" = 100;
      "vm.dirty_background_ratio" = 1;
      "vm.dirty_ratio" = 50;
      "dev.i915.perf_stream_paranoid" = 0;
    };

    loader = {

      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot/efi";
      };
      timeout = 6;

      ###  Systemd boot as bootloader ###
      # systemd-boot = {
      #   enable = true;
      #   configurationLimit = 5; # Limit the amount of configurations
      # };
      # efi.canTouchEfiVariables = true;
      # timeout = 6; # Grub auto select time

      ### Grub as bootloader ###
      grub = {

        ### For legacy boot  ###
        #   enable = true;
        #   version = 2;
        #   device = "/dev/vda"; # Name of hard drive (can also be sda)
        #   gfxmodeBios = "1920x1080";
        # };
        # timeout = 1; # Grub auto select timeout

        ## For UEFI boot
        enable = true;
        version = 2;
        # default = 0;              # "saved";
        # devices = [ "nodev" ]; # device = "/dev/sda"; or "nodev" for efi only
        # device = "/dev/vda";      # legacy
        device = "nodev"; # uefi
        efiSupport = true;
        efiInstallAsRemovable = true;
        configurationLimit = 5; # do not store more than 5 gen backups
        forceInstall = true; # force installation
        # splashMode = "stretch";
        # theme = "";               # set theme

        ## If using zfs filesystem
        # zfsSupport = true;        # enable zfs
        # copyKernels = true;       # https://nixos.wiki/wiki/NixOS_on_ZFS

        useOSProber = false; # check for other systems
        fsIdentifier = "label"; # mount devices config using label
        gfxmodeEfi = "1920x1080";
        ## If tpm is activated
        # trustedBoot.systemHasTPM = "YES_TPM_is_activated"
        # trustedBoot.enable = true;

        ## Nvidia
        # extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

        ## For encrypted boot
        # enableCryptodisk = true;  # 

        ## Add more entries for grub
        extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
      };
    };
  };

  services = {
    xserver = {
      resolutions = [
        { x = 1920; y = 1080; }
        # { x = 1600; y = 900; }
        # { x = 3840; y = 2160; }
      ];
    };
  };
}
