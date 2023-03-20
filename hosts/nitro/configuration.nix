# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  user="juca";
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # <home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  # import /persist into initial ramdisk so that tmpfs can access persisted data like user passwords
  # https://www.reddit.com/r/NixOS/comments/o1er2p/tmpfs_as_root_but_without_hardcoding_your/h22f1b9/
  # https://search.nixos.org/options?channel=21.05&show=fileSystems.%3Cname%3E.neededForBoot&query=fileSystems.%3Cname%3E.neededForBoot
  #fileSystems."/persist".neededForBoot = true; # ZFS

  boot = {
    plymouth.theme = "breeze";
    plymouth.enable = true;
    # checkJournalingFS = false; # Disable journaling check on boot because virtualbox doesn't need it
    # extraModprobeConfig = ''
    #   install iTCO_wdt /bin/true
    #   install iTCO_vendor_support /bin/true
    # '';
    kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages; # zfs
    # initrd.kernelModules = ["i915" "nvidia"];
    ### Use the GRUB 2 boot loader. ###
    # supportedFilesystems = [ "vfat" "zfs" ];
    supportedFilesystems = [ "vfat" "btrfs" ];
    ### Virtual Machine ###
    initrd.kernelModules =  [ "z3fold" "crc32c-intel" "lz4hc" "lz4hc_compress" ];

    # kernelParams = [ "elevator=none" "intel_idle.max_cstate=1" ]; #zfs
    kernelParams = [ "quiet" "splash" "loglevel=0" "gpt" "init_on_alloc=0" "udev.log_level=0" "intel_iommu=on,igfx_off" "zswap.enabled=1" "zswap.compressor=lz4hc" "zswap.max_pool_percent=10" "zswap.zpool=z3fold" "mitigations=off" "nowatchdog" "msr.allow_writes=on" "pcie_aspm=force" "module.sig_unenforce" "intel_idle.max_cstate=1" "cryptomgr.notests" "initcall_debug" "net.ifnames=0" "no_timer_check" "noreplace-smp" "page_alloc.shuffle=1" "rcupdate.rcu_expedited=1" "tsc=reliable" ];
    # zfs = {
    # requestEncryptionCredentials = true; # enable if using ZFS encryption, ZFS will prompt for password during boot
    # };
    kernel.sysctl = { "vm.vfs_cache_pressure"= 500; "vm.swappiness"=100; "vm.dirty_background_ratio"=1; "vm.dirty_ratio"=50; "dev.i915.perf_stream_paranoid"=0; };
    loader = {
      grub = {
        enable = true;
        version = 2;
        # default = 0;  # "saved";
        device = "nodev"; # device = "/dev/sda"; or "nodev" for efi only
        # device = "/dev/vda"; # legacy
        efiSupport = true;
        efiInstallAsRemovable = true;
        configurationLimit = 5; # do not store more than 5 gen backups
        # zfsSupport = true; # enable zfs
        # copyKernels = true; # https://nixos.wiki/wiki/NixOS_on_ZFS
        # useOSProber = true; # check for other systems
        fsIdentifier = "label"; # mount devices config using label
        gfxmodeEfi = "1920x1080";
        # gfxmodeBios = "1920x1080";
        # trustedBoot.systemHasTPM = "YES_TPM_is_activated"
        # trustedBoot.enable = true;
        # extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
      };
      efi = {
        efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = false;
      };
      timeout = 3;
    };
    # zfs.requestEncryptionCredentials = true;
  };

  # services.zfs = {
  #   autoScrub.enable = true;
  #   autoSnapshot.enable = true;
  #   # TODO: autoReplication
  # };

  ### NETWORK ### 
  # head -c 8 /etc/machine-id 
  # networking.hostId = "46eb1cf2"; # needed for zfs
  networking.hostName = "nixdev"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking = {
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    # interfaces = {
    #   wlan0 = { #wlp0s20f3
    #     #useDHCP = true;
    #     ipv4.addresses = [ {
    #       address = 192.168.1.50;  # static ip address
    #       prefixLength = 24;
    #     } ];
    #   };
    #   eth0 = { #enp6s0f1 
    #     #useDHCP = true;
    #     ipv4.addresses = [ {
    #       address = 192.168.1.35;
    #       prefixLength = 24;
    #     } ];
    #   }
    # };
    # defaultGateway = "192.168.1.1";
    nameservers = [
      "8.8.8.8"
      "8.8.8.8" 
      "1.1.1.1" 
    ];
  };
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  
  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";
  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
    };
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
    # useXkbConfig = true; # use xkbOptions in tty.
  };

  ### Enable the X11 windowing system. ###
  ### Enable the Desktop Environment. ###
  services = {
    xserver = {
      enable = true;
      displayManager = {
        lightdm = {
          enable = true;
          greeters = {
            slick = {
              enable = true;
              theme.name = "Adwaita";
              iconTheme.name = "Adwaita";
            };
          };
        };
      };
      desktopManager = { # any DM you like
        # defaultSession = "xfce"; 
        xfce.enable = true;
      };
      # windowManager.bspwm.enable = true;
    };
  };

  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  

  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };
  hardware = {
    bluetooth = {
      enable = true;
      hsphfpd.enable = true;  # HSP & HFP daemon
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    pulseaudio.enable = true;
  };
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;
    touchpad.tapping = true;
    # naturalScrolling = true;
    # ...
  };

  ### Doas instead of sudo 
  # security.doas.enable = true;
  # security.sudo.enable = false;
  # # Configure doas
  # security.doas.extraRules = [{
  #   users = [ "${user}" ];
  #   keepEnv = true;
  #   persist = true;  
  # }];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "video" "networkmanager" "lp" "scanner" "libvirtd"]; # Enable ‘sudo’ for the user.
    initialPassword = "teste";
    packages = with pkgs; [
      firefox
      htop
      neovim
      duf 
      neofetch
      podman
      podman-compose
      pods
      distrobox
      virt-manager
      # nvtop-nvidia
      # nvidia-podman
    ];
  };
  services.plex.enable = false;
  nixpkgs.config.allowUnfree = true; # unfree packages
  
  virtualisation.libvirtd.enable = true; # virtmanager
  programs.dconf.enable = true; # virtmanager
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    virtmanager
    qemu
    pciutils
    kmod
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  ################################################################################
  # GnuPG & SSH
  ################################################################################

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  #   permitRootLogin = "no";
  #   passwordAuthentication = true;
  #   hostKeys =
  #     [
  #       {
  #         path = "/persist/etc/ssh/ssh_host_ed25519_key";
  #         type = "ed25519";
  #       }
  #       {
  #         path = "/persist/etc/ssh/ssh_host_rsa_key";
  #         type = "rsa";
  #         bits = 4096;
  #       }
  #     ];
  };
  
  # Enable GnuPG Agent
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  ################################################################################
  # XServer & Drivers
  ################################################################################
  
  # hardware.opengl = {
  	# driSupport = true;  # install and enable Vulkan: https://nixos.org/manual/nixos/unstable/index.html#sec-gpu-accel
  	#extraPackages = [ vaapiIntel libvdpau-va-gl vaapiVdpau intel-ocl ];  # only if using Intel graphics
  # };
  
  # { pkgs, ... }:
  
  # let
  # nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
  #   export __NV_PRIME_RENDER_OFFLOAD=1
  #   export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
  #   export __GLX_VENDOR_LIBRARY_NAME=nvidia
  #   export __VK_LAYER_NV_optimus=NVIDIA_only
  #   exec -a "$0" "$@"
  # '';
  # in
  
  # {
  #   environment.systemPackages = [ nvidia-offload ];

  #   hardware.nvidia.prime = {
  #   offload.enable = true;

  #   # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
  #   intelBusId = "PCI:0:2:0";

  #   # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
  #   nvidiaBusId = "PCI:1:0:0";
  #   };
  # };
  # # Enable X11 + Nvidia
  # https://nixos.org/manual/nixos/unstable/index.html#sec-gnome-gdm
  # services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = {
    stateVersion = "22.11"; # Did you read the comment?
    autoUpgrade = {
      enable = true;
      channel = "https://nixos.org/channels/nixos-22.11";
      dates = "13:00";
      # flake = "/server";
      flags = [
        "--update-input" "nixpkgs"
    ];
    # allowReboot = true;
    };
  };

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    # Flakes
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  # mkdir -pv ~/.flakes
  # nix flake init 

  nixpkgs.overlays = [
    (self: super: {
      discord = super.discord.overrideAttrs (
        _: { src = builtins.fetchTarball {
          url = "https://discord.com/api/download?platform=linux&format=tar.gz"
          ;
          sha256 =
          "0000000000000000000000000000000000000000000000000000";
        };}
      );
    })
  ];

  ### HOME MANAGER ###
  #home-manager = {
  #  useGlobalPkgs = true;
  #  users.${user} = { pkgs, ... }: {
  #    # home.packages = with pkgs; [ gparted speedtest-cli ];
  #    home.packages =  [ pkgs.gparted ];
  #    home.stateVersion = "22.11";
  #    # programs.bash.enable = true;
  #    # home-manager.useGlobalPkgs = true;
  #  };
  #};
}

### Add Home Manager
# sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz home-manager
# nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager