#  flake.nix *             
#   ├─ ./hosts
#   │   └─ default.nix
#   ├─ ./darwin
#   │   └─ default.nix
#   └─ ./nix
#       └─ default.nix

{
  description = "Setup NixOS for my devices";
  
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";                  # Nix Packages

    home-manager = {
      url = github:nix-community/home-manager;                            # User Package Management
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
        url = "github:lnl7/nix-darwin/master";                            # MacOS Package Management
        inputs.nixpkgs.follows = "nixpkgs";
      };

    nur = {                                                               # NUR Packages
        url = "github:nix-community/NUR";                                   # Add "nur.nixosModules.nur" to the host modules
      };

    nixgl = {                                                             # OpenGL
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {                                                     # Emacs Overlays
        url = "github:nix-community/emacs-overlay";
        flake = false;
      };

    doom-emacs = {                                                        # Nix-community Doom Emacs
      url = "github:nix-community/nix-doom-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs-overlay";
    };
    hyprland = {                                                          # Official Hyprland flake
      url = "github:vaxerski/Hyprland";                                   # Add "hyprland.nixosModules.default" to the host modules
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {                                                    # KDE Plasma user settings
      url = "github:pjones/plasma-manager";                               # Add "inputs.plasma-manager.homeManagerModules.plasma-manager" to the home-manager.users.${user}.imports
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "nixpkgs";
    };
  };

  # outputs = { self, nixpkgs }: 
  outputs = { self, nixpkgs, home-manager }: 

    let
      user="juca";
      location = "$HOME/.setup";
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        juca = lib.nixosSystem {
          inherit system;
          modules = [ 
            ./configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${user} = {
                imports = [ 
                 ./home.nix
                ];
              };
            }
         ];
        };
      };

      # homeManagerConfiguration = {
      #   pkgs = nixpkgs.legacyPackages.${system};
      #   modules = [
      #     # ./home.nix
      #     # ./some-extra-module.nix
      #     {
      #       home = {
      #         username = "${user}";
      #         homeDirectory = "/home/${user}";
      #         stateVersion = "22.11";
      #       };
      #     }
      #   ];
      # };
    };
}

# sudo nixos-rebuild switch --flake .#juca
# sudo nixos-rebuild switch --flake <path>#<hostname>