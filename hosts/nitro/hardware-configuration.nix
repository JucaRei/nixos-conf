#
# Hardware settings for HP ProBook 650 G1 15.6" Laptop
# Dual boot active. Windows @ sda4 / NixOS @ sda5
#
# flake.nix
#  └─ ./hosts
#      └─ ./laptop
#          └─ hardware-configuration.nix *
#
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
#
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  hostname = "nitro";
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    consoleLogLevel = 0;
    # cleanTmpDir = true; # delete all files in /tmp during boot.
    initrd = {
      availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      kernelModules = [];
      supportedFilesystems = ["vfat" "btrfs"];
      compressor = "zstd";
    };
    kernelModules = ["kvm-intel" "z3fold" "crc32c-intel" "lz4hc" "lz4hc_compress" "zram" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
    # kernelParams = [ "quiet" "apparmor=1" "usbcore.autosuspend=-1" "intel_pstate=hwp_only" "security=apparmor" "kernel.unprivileged_userns_clone" "vt.global_cursor_default=0" "loglevel=0" "gpt" "init_on_alloc=0" "udev.log_level=0" "rd.driver.blacklist=grub.nouveau" "rcutree.rcu_idle_gp_delay=1" "intel_iommu=on,igfx_off" "nvidia-drm.modeset=1" "i915.enable_psr=0" "i915.modeset=1" "zswap.enabled=1" "zswap.compressor=lz4hc" "zswap.max_pool_percent=25" "zswap.zpool=z3fold" "mitigations=off" "nowatchdog" "msr.allow_writes=on" "pcie_aspm=force" "module.sig_unenforce" "intel_idle.max_cstate=1" "cryptomgr.notests" "initcall_debug" "net.ifnames=0" "no_timer_check" "noreplace-smp" "page_alloc.shuffle=1" "rcupdate.rcu_expedited=1" "tsc=reliable" ];
    kernelParams = ["quiet" "gpt" "intel_iommu=on,igfx_off" "zswap.enabled=1" "zswap.compressor=lz4hc" "zswap.max_pool_percent=25" "zswap.zpool=z3fold" "mitigations=off" "intel_idle.max_cstate=1" "net.ifnames=0" "mem_sleep_default=deep"];
    #extraModulePackages = [ "config.boot.kernelPackages.nvidia_x11" ];
    supportedFilesystems = ["vfat" "btrfs"];
    #kernelPackages = pkgs.linuxPackages_latest;

    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernel.sysctl = {
      "vm.vfs_cache_pressure" = 500;
      "vm.swappiness" = 100;
      "vm.dirty_background_ratio" = 1;
      "vm.dirty_ratio" = 50;
      "dev.i915.perf_stream_paranoid" = 0;
    };
    # extraModprobeConfig = ''
    #   "install iTCO_wdt /bin/true"
    #   "install iTCO_vendor_support /bin/true"

    #   "options i915 enable_guc=2 enable_fbc=1 enable_dc=4 enable_hangcheck=0 error_capture=0 enable_dp_mst=0 fastboot=1 #parameters may differ"
    #   "options nvidia_drm modeset=1"
    #   "options nouveau modeset=0"
    # '';
    # blacklistedKernelModules = [ ];
    ### Enable plymouth ###
    plymouth = {
      theme = "breeze";
      enable = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "btrfs";
    options = ["subvol=@root" "rw" "noatime" "nodiratime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "btrfs";
    options = ["subvol=@home" "rw" "noatime" "nodiratime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async"];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "btrfs";
    options = ["subvol=@snapshots" "rw" "noatime" "nodiratime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async"];
  };

  fileSystems."/var/tmp" = {
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "btrfs";
    options = ["subvol=@tmp" "rw" "noatime" "nodiratime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "btrfs";
    options = ["subvol=@nix" "rw" "noatime" "nodiratime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async"];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-partlabel/GRUB";
    fsType = "vfat";
    options = ["defaults" "noatime" "nodiratime"];
    noCheck = true;
  };

  swapDevices = [];

  networking = {
    interfaces = {
      eth0 = {
        useDHCP = true; # For versatility sake, manually edit IP on nm-applet.
        # ipv4.addresses = [
        #   {
        #     address = "192.168.1.35";
        #     prefixLength = 24;
        #   }
        # ];
      };

      wlan0 = {
        useDHCP = true;
        # ipv4.addresses = [
        #   {
        #     address = "192.168.1.50";
        #     prefixLength = 24;
        #   }
        # ];
      };
    };
    # useDHCP = false; # Deprecated
    hostName = "${hostname}";
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
        networkmanager-openconnect
      ];
    };
    defaultGateway = "192.168.1.1";
    nameservers = ["192.168.1.4"];
    firewall = {
      enable = false;
      #allowedUDPPorts = [ 53 67 ];
      #allowedTCPPorts = [ 53 80 443 9443 ];
    };
  };

  zramSwap = {
    enable = true;
    swapDevices = 4;
    memoryPercent = 20; # 20% of total memory
    algorithm = "zstd";
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    sane = {
      # Used for scanning with Xsane
      enable = true;
      extraBackends = [pkgs.sane-airscan];
    };
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        # vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
  services = {
    btrfs.autoScrub.enable = true;
    logind.lidSwitch = "suspend";
    thermald.enable = true;
    power-profiles-daemon.enable = false; # needed to use tlp
    tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 0; # dummy value
        STOP_CHARGE_THRESH_BAT0 = 1; # battery conservation mode
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };

    upower.enable = true;
  };
}
