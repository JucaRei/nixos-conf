{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "Testing Flakes";
  buildInputs = with pkgs; [
    nixFlakes
  ];
  shellHook = ''
    echo "Enviroment to test flakes";
  '';
}
