#
#  G'Day
#  Behold is my personal Nix, NixOS and Darwin Flake.
#  I'm not the sharpest tool in the shed, so this build might not be the best out there.
#  I refer to the README and other org document on how to use these files.
#  Currently and possibly forever a Work In Progress.
#
#  flake.nix *             
#   ├─ ./hosts
#   │   └─ default.nix
#   ├─ ./darwin
#   │   └─ default.nix
#   └─ ./nix
#       └─ default.nix
#

{
  description = "My Personal NixOS and Darwin System Flake Configuration";

  inputs = # All flake references used to build my NixOS setup. These are dependencies.
    {
      # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";                  # Nix Packages

      nixpkgs-2211.url = "github:nixos/nixpkgs/nixos-22.11";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
      master.url = "github:nixos/nixpkgs/master";

      # The following is required to make flake-parts work.
      nixpkgs.follows = "nixpkgs-unstable";
      unstable.follows = "nixpkgs-unstable";
      stable.follows = "nixpkgs-2211";

      home-manager = {
        # User Package Management
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      darwin = {
        url = "github:lnl7/nix-darwin/master"; # MacOS Package Management
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nur = {
        # NUR Packages
        url = "github:nix-community/NUR"; # Add "nur.nixosModules.nur" to the host modules
      };

      nixgl = {
        # OpenGL
        url = "github:guibou/nixGL";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      emacs-overlay = {
        # Emacs Overlays
        url = "github:nix-community/emacs-overlay";
        flake = false;
      };

      doom-emacs = {
        # Nix-community Doom Emacs
        url = "github:nix-community/nix-doom-emacs";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.emacs-overlay.follows = "emacs-overlay";
      };

      hyprland = {
        # Official Hyprland flake
        url = "github:vaxerski/Hyprland"; # Add "hyprland.nixosModules.default" to the host modules
        inputs.nixpkgs.follows = "nixpkgs";
      };

      plasma-manager = {
        # KDE Plasma user settings
        url = "github:pjones/plasma-manager"; # Add "inputs.plasma-manager.homeManagerModules.plasma-manager" to the home-manager.users.${user}.imports
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.home-manager.follows = "nixpkgs";
      };
    };

  outputs = inputs @ { self, nixpkgs, home-manager, darwin, nur, nixgl, doom-emacs, hyprland, plasma-manager, ... }: # Function that tells my flake which to use and what do what to do with the dependencies.
    let
      # Variables that can be used in the config files.
      user = "juca";   # Set the name of user for each host you want to install
      location = "$HOME/.setup";
      computerName = "vmbox";      # Set the computer name for each host you want to install
      hostname = "teste";      # Set the hostname name for each host you want to install
    in
    # Use above variables in ...
    {
      nixosConfigurations = (
        # NixOS configurations
        import ./hosts {
          # Imports ./hosts/default.nix
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager nur user computerName hostname location doom-emacs hyprland plasma-manager; # Also inherit home-manager so it does not need to be defined here.
        }
      );

      darwinConfigurations = (
        # Darwin Configurations
        import ./darwin {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager darwin user computerName hostname;
        }
      );

      homeConfigurations = (
        # Non-NixOS configurations
        import ./nix {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager nixgl user computerName hostname;
        }
      );
    };
}
