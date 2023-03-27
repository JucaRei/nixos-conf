#
# Docker
#

{ config, pkgs, user, ... }:

{
  virtualisation = {
    podman = {
      enable = true;
      enableNvidia = true;
      dockerSocket.enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;

      # # Needed for ZFS System
      # extraPackages = [
      #   pkgs.zfs
      # ];
    };
    containers = {
      registries.search = [
        "docker.io"
        # "registry.fedoraproject.org"
        # "quay.io"
        # "registry.access.redhat.com"
        # "registry.centos.org"
      ];
      containersConf.settings = {
        containers.dns_servers = [
          "8.8.8.8"
          "8.8.4.4"
        ];
      };
      ## for ZFS
      # storage = {
      #   settings = {
      #     driver = "zfs";
      #     graphroot = "/var/lib/containers/storage";
      #     runroot = "/run/containers/storage";
      #     options.zfs.fsname = "zroot/podman";
      #   };
      # };
    };
  };

  users.groups.podman.members = [ "${user}" ];

  #environment = {
  #  interactiveShellInit = ''
  #    alias rtmp='docker start nginx-rtmp'
  #  '';                                                           # Alias to easily start container
  #};

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
