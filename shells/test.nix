{pkgs ? import <nixpkgs> {}}: let
  # Just like aliases from bashscript
  myscript = pkgs.writeScriptBin "teste" ''
    echo "Testando" | figlet
  '';
in
  pkgs.mkShell {
    name = "MyAwesomeShell";
    buildInputs = with pkgs; [
      # Packages inside the Shell
      figlet
      # Adicionando scripts
      myscript
    ];

    # Startup script
    shellHook = ''
      echo "Welcome to my awesome shell";
    '';
  }
# name it to shell.nix or default.nix

