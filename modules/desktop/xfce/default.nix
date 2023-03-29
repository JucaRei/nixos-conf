#
# XFCE4 configuration
#
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    zsh.enable = true;
    dconf.enable = true;
    kdeconnect = {
      # For GSConnect
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };

  services = {
    xserver = {
      enable = true;

      # Brazil layout
      layout = "br"; # Keyboard layout
      xkbModel = "pc105";
      xkbVariant = "nativo";
      # xkbVariant = "nativo-us"; # nativo for us keyboards

      # Mac
      # layout = "us"; # Keyboard layout
      # xkbModel = "pc105";
      # xkbVariant = "mac";

      libinput.enable = true;

      displayManager = {
        # setupCommands = ''
        #   LEFT='HDMI-1-0'
        #   # CENTER='DVI-I-1'
        #   RIGHT='eDP-1'
        #   ${pkgs.xorg.xrandr}/bin/xrandr --output $LEFT --rotate left --left-of --output $RIGHT --right-of $LEFT
        # '';
        gdm.enable = true; # Display Manager
      };
      desktopManager.gnome.enable = true; # Window Manager
    };
    udev.packages = with pkgs; [
      gnome.gnome-settings-daemon
    ];
  };

  hardware.pulseaudio.enable = false;

  environment = {
    systemPackages = with pkgs; [
      # Packages installed
      gnome.dconf-editor
      gnome.gnome-tweaks
      gnome.adwaita-icon-theme
    ];
    gnome.excludePackages =
      (with pkgs; [
        # Gnome ignored packages
        gnome-tour
      ])
      ++ (with pkgs.gnome; [
        gedit
        epiphany
        geary
        gnome-characters
        tali
        iagno
        hitori
        atomix
        yelp
        gnome-contacts
        gnome-initial-setup
      ]);
  };
}
