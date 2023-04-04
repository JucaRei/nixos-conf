#
#  Main system configuration. More information available in configuration.nix(5) man page.
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ configuration.nix *
#   └─ ./modules
#       ├─ ./editors
#       │   └─ default.nix
#       └─ ./shell
#           └─ default.nix
#
{
  config,
  lib,
  pkgs,
  inputs,
  user,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  extraGroups =
    [
      "wheel"
      "video"
      "audio"
    ]
    ++ ifTheyExist [
      "network"
      "networkmanager"
      "docker"
      "git"
      "camera"
      "networkmanager"
      "lp"
      "scanner"
      "kvm"
      "libvirtd"
      "plex"
    ];
in {
  imports =
    (import ../modules/editors)
    ++ # Native doom emacs instead of nix-community flake
    (import ../modules/shell);

  users.users.${user} = {
    # System User
    # isSystemUser = true;
    isNormalUser = true;
    # description = "Nixos"; # you can set your Full Name here, if you like it.
    # group = "nixuser";
    createHome = true;
    uid = 1000;
    autoSubUidGidRange = true; # Allocated range is currently always of size 65536
    initialPassword = "123"; # remember of changing the password when log in.
    # extraGroups = ["wheel" "video" "audio" "camera" "networkmanager" "lp" "scanner" "kvm" "libvirtd" "plex"];
    inherit extraGroups;
    shell = pkgs.zsh; # Default shell
    # shell = "/bin/bash"
  };
  security.sudo.wheelNeedsPassword = false; # User does not need to give password when using sudo.

  time = {
    timeZone = "America/Sao_Paulo"; # Time zone and internationalisation
    hardwareClockInLocalTime = true; # hardware clock in local time instead of UTC
  };
  i18n = {
    # defaultLocale = "en_US.UTF-8";
    # supportedLocales = [
    #   "pt_BR.UTF-8"
    #   "en_US.UTF-8"
    # ];
    extraLocaleSettings = {
      # Extra locale settings that need to be overwritten
      LANG = "en_US.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us-acentos"; # or us/azerty/etc
    # keyMap = "br-abnt2"; # or us/azerty/etc
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    # tpm2.enable = true;
    # unprivilegedUsernsClone = true;
  };
  #sound = {                                # Deprecated due to pipewire
  #  enable = true;
  #  mediaKeys = {
  #    enable = true;
  #  };
  #};

  fonts = {
    fonts = with pkgs; [
      # Fonts
      carlito # NixOS
      vegur # NixOS
      source-code-pro
      jetbrains-mono
      lato
      roboto
      iosevka-bin
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome # Icons
      corefonts # MS
      (nerdfonts.override {
        # Nerdfont Icons override
        fonts = [
          "FiraCode"
          "Iosevka"
          "JetBrainsMono"
        ];
      })
    ];

    enableDefaultFonts = false;

    # this fixes emoji stuff
    fontconfig = {
      defaultFonts = {
        monospace = [
          "Iosevka Term"
          "Iosevka Term Nerd Font Complete Mono"
          "Iosevka Nerd Font"
          "Noto Color Emoji"
        ];
        sansSerif = ["Lexend" "Noto Color Emoji"];
        serif = ["Noto Serif" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
  environment = {
    variables = {
      TERMINAL = "alacritty";
      EDITOR = "nvim";
      # LC_ALL = "en_US.UTF-8";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [
      # Default packages installed system-wide
      #vim
      #git
      killall
      nano
      pciutils
      usbutils
      #wget
      # Add Direnv
      direnv
      nix-direnv
    ];
    # Direnv
    pathsTolink = [
      "/share/nix-direnv"
    ];
  };

  services = {
    printing = {
      # Printing and drivers for TS5300
      enable = true;
      #drivers = [ pkgs.cnijfilter2 ];          # There is the possibility cups will complain about missing cmdtocanonij3. I guess this is just an error that can be ignored for now. Also no longer need required since server uses ipp to share printer over network.
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
    # Pipewire as default
    pipewire = {
      # Sound
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    openssh = {
      # SSH: secure shell (remote connection to shell of server)
      #enable = true; # local: $ ssh <user>@<ip>
      startWhenNeeded = true; #systemd will start an instance for each incoming connection.
      # public:
      #   - port forward 22 TCP to server
      #   - in case you want to use the domain name insted of the ip:
      #       - for me, via cloudflare, create an A record with name "ssh" to the correct ip without proxy
      #   - connect via ssh <user>@<ip or ssh.domain>
      # generating a key:
      #   - $ ssh-keygen   |  ssh-copy-id <ip/domain>  |  ssh-add
      #   - if ssh-add does not work: $ eval `ssh-agent -s`
      allowSFTP = true; # SFTP: secure file transfer protocol (send file to server)
      # connect: $ sftp <user>@<ip/domain>
      #   or with file browser: sftp://<ip address>
      # commands:
      #   - lpwd & pwd = print (local) parent working directory
      #   - put/get <filename> = send or receive file
      extraConfig = ''
        HostKeyAlgorithms +ssh-rsa
      ''; # Temporary extra config so ssh will work in guacamole
    };
    flatpak.enable = true; # download flatpak file from website - sudo flatpak install <path> - reboot if not showing up
    # sudo flatpak uninstall --delete-data <app-id> (> flatpak list --app) - flatpak uninstall --unused
    # List:
    # com.obsproject.Studio
    # com.parsecgaming.parsec
    # com.usebottles.bottles
  };

  nix = {
    # Nix Package Manager settings
    optimise.automatic = true;
    settings = {
      auto-optimise-store = true; # Optimise syslinks
      warn-dirty = false;

      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;
    };
    gc = {
      # Automatic garbage collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };
    package = pkgs.nixVersions.unstable; # Enable nixFlakes on system
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
      keep-outputs          = true
      keep-derivations      = true
    '';
  };
  nixpkgs.config = {
    allowUnfree = true; # Allow proprietary software.
    # allowUnsupportedSystem = true; # For permanently allowing unsupported packages to be built.

    allowUnfreePredicate = _: true; # Workaround for https://github.com/nix-community/home-manager/issues/2942
    # For support flakes with direnv
    overlays = [
      (self: super: {nix-direnv = super.nix-direnv.override {enableFlakes = true;};})
    ];
  };

  system = {
    # NixOS settings
    autoUpgrade = {
      # Allow auto update (not useful in flakes)
      #enable = true;
      #channel = "https://nixos.org/channels/nixos-unstable";
      channel = "https://nixos.org/channels/nixos-22.11";
      dates = "22:00";
      flags = [
        "--update-input"
        "nixpkgs"
        "--commit-lock-file"
      ];
      # allowReboot = true;
    };
    stateVersion = "22.11";
  };

  # if you also want support for flakes
  nixpkgs.overlays = [
    (self: super: {nix-direnv = super.nix-direnv.override {enableFlakes = true;};})
  ];
}
