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
{
  config,
  pkgs,
  user,
  ...
}: {
  imports =
    # For now, if applying to other system, swap files
    [(import ./hardware-configuration.nix)]
    ++ # Current system hardware config @ /etc/nixos/hardware-configuration.nix
    [(import ../../modules/desktop/gnome/default.nix)]
    ++ # Gnome
    [(import ../../modules/programs/games.nix)]
    ++ # Gaming
    (import ../../modules/desktop/virtualisation)
    ++ # Virtual Machines & VNC
    (import ../../modules/hardware/work); # Nvidia

  boot = {
    isContainer = false;
    # Boot options

    loader = {
      # EFI Boot
      efi = {
        canTouchEfiVariables = false; # EFI
        efiSysMountPoint = "/boot/efi";
      };
      timeout = 5; # Grub auto select time

      grub = {
        # Most of grub is set up for dual boot
        enable = true;
        version = 2;
        devices = ["nodev"];
        efiSupport = true;
        efiInstallAsRemovable = true;
        useOSProber = true; # Find all boot options
        configurationLimit = 5; # do not store more than 5 gen backups
        forceInstall = true; # force installation
        fsIdentifier = "label"; # Identify mount points by label
        # gfxmodeEfi = "1920x1080";
        # zfsSupport = true;  # if using zfs
        fontSize = 20;
        configurationName = "NixOS Nitro 5";
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

  environment = {
    systemPackages = with pkgs; [
      simple-scan
      x11vnc
    ];
    # variables = {
      # LIBVA_DRIVER_NAME = "i965";
      # LIBVA_DRIVER_NAME = "i915";
    # };
  };

  programs = {
    # No xbacklight, this is the alternative
    dconf.enable = true;
    light.enable = true;
  };

  services = {
    tlp.enable = true; # TLP and auto-cpufreq for power management
    #logind.lidSwitch = "ignore";           # Laptop does not go to sleep when lid is closed
    #     auto-cpufreq.enable = true;
    blueman.enable = true;
    printing = {
      # Printing and drivers for TS5300
      enable = true;
      drivers = [pkgs.cnijfilter2];
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
          "read only" = "yes";
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
    targets."bluetooth".after = ["systemd-tmpfiles-setup.service"];
  };
}
