#
#  Home-manager configuration for desktop
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./vm
#   │       └─ home.nix *
#   └─ ./modules
#       └─ ./desktop
#           └─ ./bspwm
#               └─ home.nix
#

{ config, pkgs, lib, ... }:

{
  imports =
    [
      # ../../modules/desktop/bspwm/home.nix #Window Manager
      ../../modules/desktop/gnome/home.nix #Window Manager
    ];

  i18n = {
    defaultLocale = "en_US.UTF-8";
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

  home = {
    # Specific packages for desktop
    packages = with pkgs; [
      firefox
      neofetch
      htop
    ];
  };
}
