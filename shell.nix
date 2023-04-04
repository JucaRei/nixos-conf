## Shell for bootstrapping flake-enabled nix and home-manager
#{pkgs ? import <nixpkgs> {}}:
#pkgs.mkShell {
#  name = "nixosbuildshell";
#  nativeBuildInputs = with pkgs; [
#    git
#    # git-crypt
#    nix-direnv
#    nil
#    nixFlakes
#    home-manager
#    neovim
#    nano
#  ];
#
#  shellHook = ''
#    alias build="echo build"
#      echo "You can apply this flake to your system with nixos-rebuild switch --flake .#"
#      PATH=${pkgs.writeShellScriptBin "nix" ''
#      ${pkgs.nixFlakes}/bin/nix --experimental-features "nix-command flakes" "$@"
#    ''}/bin:$PATH
#  '';
#}
# Shell for bootstrapping flake-enabled nix and home-manager
# You can enter it through `nix develop` or (legacy) `nix-shell`
{pkgs ? (import ./nixpkgs.nix) {}}: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [nix home-manager git];
  };
}
