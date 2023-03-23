#
#  These are the different profiles that can be used when building on MacOS
#
#  flake.nix
#   └─ ./darwin
#       ├─ ./default.nix *
#       ├─ configuration.nix
#       └─ home.nix
#

{ lib, inputs, nixpkgs, home-manager, darwin, user, ...}:

let
  system = "x86_64-darwin";                                 # System architecture
in
{
  macbook = darwin.lib.darwinSystem {                       # MacBook4,1 
    inherit system;
    specialArgs = { inherit user inputs; };
    modules = [                                             # Modules that are used
      ./configuration.nix
      
      home-manager.darwinModules.home-manager {             # Home-Manager module that is used
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit user computerName hostname; };  # Pass flake variable
        home-manager.users.${user} = import ./home.nix;
      }
    ];
  };
}
