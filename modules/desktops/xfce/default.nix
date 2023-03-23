#
# KDE Plasma 5 configuration
#

{ config, lib, pkgs, ... }:

{
  programs = {
    zsh.enable = true;
    dconf.enable = true;
    kdeconnect = {                                # For GSConnect
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };

  services = {
    xserver = {
      enable = true;

      layout = "pt_BR";                              # Keyboard layout BR
      # xkbOptions = "eurosign:e";
      libinput.enable = true;
      # modules = [ pkgs.xf86_input_wacom ];        # Both needed for wacom tablet usage
      # wacom.enable = true;

      displayManager = {
        defaultSession = "xfce"; 
        lightdm = {
          enable = true;
          greeters = {
            slick = {
              enable = true;
              theme.name = "Adwaita";
              iconTheme.name = "Adwaita";
            };
          };
        };
      };

      desktopManager = {         # any DM you like
        xfce = {
          enable = true;
          excludePackages = with pkgs.libsForQt5; [
          elisa
          khelpcenter
          konsole
          oxygen
          ];
        };
      };
      # windowManager.bspwm.enable = true;
    };
  };

  #hardware.pulseaudio.enable = false;

  environment = {
    systemPackages = with pkgs.libsForQt5; [                 # Packages installed
      packagekit-qt
      bismuth
    ];

  };
}