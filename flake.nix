#  flake.nix *
#   ├─ ./hosts
#   │   └─ default.nix
#   ├─ ./darwin
#   │   └─ default.nix
#   └─ ./nix
#       └─ default.nix
#
{
  description = "My Personal NixOS configs and examples";

  inputs =
    # All flake references used to build my NixOS setup. These are dependencies.
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11"; # primary nixpkgs
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"; # for packages on the edge
      nixpkgs-master.url = "github:nixos/nixpkgs/master"; # master

      # The following is required to make flake-parts work.
      nixpkgs.follows = "nixpkgs";
      unstable.follows = "nixpkgs-unstable";
      master.follows = "nixpkgs-master";

      nixos-hardware.url = "github:NixOS/nixos-hardware/master";

      nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

      home-manager = {
        # User Package Management
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs"; # use versions from nixpkgs
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

      flake-utils.url = "github:numtide/flake-utils";
    };

  outputs = inputs @ {
    #outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-master,
    home-manager,
    nixos-hardware,
    darwin,
    nur,
    nixgl,
    doom-emacs,
    hyprland,
    plasma-manager,
    ...
  }:
  #} @ inputs:
  # Function that tells my flake which to use and what do what to do with the dependencies.
  let
    # Systems that can run tests:
    #inherit (self) outputs;
    #forAllSystems = nixpkgs.lib.genAttrs [
    #  "aarch64-linux"
    #  "aarch64-darwin"
    #  "x86_64-darwin"
    #  "x86_64-linux"
    #];
    system = "x86_64-linux";
    # # Function to generate a set based on supported systems:
    # forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;
    # # Attribute set of nixpkgs for each system:
    # nixpkgsFor = forAllSystems (system:
    #   import inputs.nixpkgs { inherit system; });
    # Variables that can be used in the config files.
    user = "juca"; # Set the name of user for each host you want to install
    location = "$HOME/.setup";
    computerName = "nitro"; # Set the computer name for each host you want to install
    hostname = "rocinante"; # Set the hostname name for each host you want to install
    monitornitro = "eDP-1";
    monitorExternal = "HDMI-1-0";
    monitormcbair = "eDP1";
    monitoroldmac = "LVDS-1";
    monitorVM = "Virtual-1";
  in
    # Use above variables in ...
    {
      # Custom packages
      # Acessible through `nix build`, `nix shell`, etc...
      #packages = forAllSystems (
      #  system: let
      #    pkgs = nixpkgs.legacyPackages.${system};
      #  in
      #    import ./pkgs {inherit pkgs;}
      #);
      ## Devshell for bootstrapping
      ## Acessible through `nix develop` or `nix-shell` (legacy)
      #devShells = forAllSystems (
      #  system: let
      #    pkgs = nixpkgs.legacyPackages.${system};
      #  in
      #    import ./shell.nix {inherit pkgs;}
      #);
      system = "x86_64-linux";
      ### Builds NIX
      nixosConfigurations = (
        # NixOS configurations
        import ./hosts {
          # Imports ./hosts/default.nix
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager nur user computerName hostname monitornitro monitorExternal monitormcbair monitoroldmac monitorVM location doom-emacs hyprland plasma-manager; # Also inherit home-manager so it does not need to be defined here.
        }
      );

      darwinConfigurations = (
        # Darwin Configurations
        import ./darwin {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager darwin user monitormcbair monitoroldmac computerName hostname;
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
