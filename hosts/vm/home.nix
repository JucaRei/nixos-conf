{ config, pkgs, ... }:
let 
user="juca";
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "22.11";
    packages = with pkgs; [ 
      ansible 
      ffmpeg
    ];
    services = {                            # Applets
    blueman-applet.enable = true;         # Bluetooth
    };
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}