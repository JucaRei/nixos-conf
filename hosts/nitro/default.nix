#  Specific system configuration settings for desktop
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./laptop
#   │        ├─ default.nix *
#   │        └─ hardware-configuration.nix
#   └─ ./modules
#       ├─ ./desktop
#       │   ├─ ./bspwm
#       │   │   └─ default.nix
#       │   └─ ./virtualisation
#       │       └─ docker.nix
#       └─ ./hardware
#           └─ default.nix
#       ├─ ./programs
#       │   └─ games.nix
#       └─ ./hardware
#           └─ default.nix
#

{ config, pkgs, user, ... }:

{
  imports = # For now, if applying to other system, swap files
    [ (import ./hardware-configuration.nix) ] ++ # Current system hardware config @ /etc/nixos/hardware-configuration.nix
    [ (import ../../modules/desktop/bspwm/default.nix) ] ++ # Window Manager
    [ (import ../../modules/desktop/virtualisation/docker.nix) ] ++ # Docker
    [ (import ../../modules/programs/games.nix) ] ++ # Gaming
    (import ../../modules/desktop/virtualisation) ++ # Virtual Machines & VNC
    (import ../../modules/hardware/work); # Nvidia

  boot = {
    isContainer = false;
    # Boot options

    loader = {

      # EFI Boot
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      timeout = 6; # Grub auto select time

      grub = {
        # Most of grub is set up for dual boot
        enable = true;
        version = 2;
        devices = [ "nodev" ];
        efiSupport = true;
        efiInstallAsRemovable = true;
        useOSProber = true; # Find all boot options
        configurationLimit = 5; # do not store more than 5 gen backups
        forceInstall = true; # force installation
        fsIdentifier = "label";
        # gfxmodeEfi = "1920x1080";
        # zfsSupport = true; 
        fontSize = 20;
        configurationName = "NixOS Stable";
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

  hardware = {
    sane = {
      # Used for scanning with Xsane
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
    };
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      simple-scan
      x11vnc
    ];
    variables = {
      # LIBVA_DRIVER_NAME = "i965";
      LIBVA_DRIVER_NAME = "i915";
    };
  };

  programs = {
    # No xbacklight, this is the alterantive
    dconf.enable = true;
    light.enable = true;
  };

  services = {
    tlp.enable = true; # TLP and auto-cpufreq for power management
    #logind.lidSwitch = "ignore";           # Laptop does not go to sleep when lid is closed
    auto-cpufreq.enable = true;
    blueman.enable = true;
    printing = {
      # Printing and drivers for TS5300
      enable = true;
      drivers = [ pkgs.cnijfilter2 ];
    };
    avahi = {
      # Needed to find wireless printer
      enable = true;
      nssmdns = true;
      publish = {
        # Needed for detecting the scanner
        enable = true;
        addresses = true;
        userServices = true;
      };
    };

    # Samba Config
    samba = {
      enable = true;
      shares = {
        share = {
          "path" = "/home/${user}";
          "guest ok" = "no";
          "read only" = "no";
        };
      };
      openFirewall = true;
    };

    ## ZFS Services
    # zfs = {
    #   autoSnapshot.enable = true;
    #   autoScrub.enable = true;
    # };
  };

  #temporary bluetooth fix
  systemd = {
    tmpfiles.rules = [
      "d /var/lib/bluetooth 700 root root - -"
    ];
    targets."bluetooth".after = [ "systemd-tmpfiles-setup.service" ];
  };
}
