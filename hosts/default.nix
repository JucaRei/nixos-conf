#
#  These are the different profiles that can be used when building NixOS.
#
#  flake.nix 
#   └─ ./hosts  
#       ├─ default.nix *
#       ├─ configuration.nix
#       ├─ home.nix
#       └─ ./desktop OR ./nitro OR ./mcbair OR ./vm
#            ├─ ./default.nix
#            └─ ./home.nix 
#

{ lib, inputs, nixpkgs, home-manager, nur, user, monitornitro, monitorExternal, monitormcbair, monitoroldmac, monitorVM, computerName, hostname, location, doom-emacs, hyprland, plasma-manager, ... }:

let
  system = "x86_64-linux";                                  # System architecture

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true; # Allow proprietary software
  };

  lib = nixpkgs.lib;

in
{
  desktop = lib.nixosSystem {
    # Desktop profile
    inherit system;
    specialArgs = {
      inherit inputs user location hyprland system hostname monitornitro monitorExternal monitormcbair monitoroldmac;
      host = {
        hostName = "${hostname}";
        mainMonitor = "${monitornitro}";
        # secondMonitor = "${monitorExternal}";
      };
    }; # Pass flake variable
    modules = [
      # Modules that are used.
      nur.nixosModules.nur
      hyprland.nixosModules.default
      ./desktop
      ./configuration.nix

      home-manager.nixosModules.home-manager
      {
        # Home-Manager module that is used.
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user doom-emacs hostname monitornitro monitorExternal;
          host = {
            hostName = "${hostname}"; #For Xorg iGPU  | Videocard 
            mainMonitor = "${monitornitro}"; #${monitorExternal}         | HDMI-A-1
            # secondMonitor = "${monitorExternal}"; #${monitornitro}            | DisplayPort-1
          };
        }; # Pass flake variable
        home-manager.users.${user} = {
          imports = [
            ./home.nix
            ./desktop/home.nix
          ];
        };
      }
    ];
  };

  nitro = lib.nixosSystem {
    # nitro profile
    inherit system;
    specialArgs = {
      inherit inputs user location hostname monitornitro monitorExternal;
      host = {
        hostName = "${hostname}";
        mainMonitor = "${monitornitro}";
        secondMonitor = "${monitorExternal}";
      };
    };
    modules = [
      # hyprland.nixosModules.default
      ./nitro
      ./configuration.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user hostname monitornitro monitorExternal;
          host = {
            hostName = "${hostname}";
            mainMonitor = "${monitornitro}";
            secondMonitor = "${monitorExternal}";
          };
        };
        home-manager.users.${user} = {
          imports = [ (import ./home.nix) ] ++ [ (import ./nitro/home.nix) ];
        };
      }
    ];
  };

  mcbair = lib.nixosSystem {
    # mcbair profile
    inherit system;
    specialArgs = {
      inherit inputs user location hostname monitormcbair monitorExternal;
      host = {
        hostName = "${hostname}";
        mainMonitor = "${monitormcbair}";
      };
    };
    modules = [
      hyprland.nixosModules.default
      ./mcbair
      ./configuration.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user hostname monitormcbair monitorExternal;
          host = {
            hostName = "${hostname}";
            mainMonitor = "${monitormcbair}";
          };
        };
        home-manager.users.${user} = {
          imports = [ (import ./home.nix) ] ++ [ (import ./mcbair/home.nix) ];
        };
      }
    ];
  };

  vm = lib.nixosSystem {
    # VM profile
    inherit system;
    specialArgs = {
      inherit inputs user location hostname monitorVM;
      host = {
        hostName = "${hostname}";
        mainMonitor = "${monitorVM}";
      };
    };
    modules = [
      ./vm
      ./configuration.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user hostname monitorVM;
          host = {
            hostName = "${hostname}";
            mainMonitor = "${monitorVM}";
          };
        };
        home-manager.users.${user} = {
          imports = [ (import ./home.nix) ] ++ [ (import ./vm/home.nix) ];
        };
      }
    ];
  };
}
