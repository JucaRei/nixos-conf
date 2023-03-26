#
#  Screen color temperature changer
#
{ config, lib, pkgs, ...}:

{
  config = lib.mkIf (config.xsession.enable) {      # Only evaluate code if using X11
    services = {
      redshift = {
        enable = true;
        temperature.night = 3000;
        latitude = -23.550520;
        longitude = -46.633308;
      };
    };
  }; 
}
