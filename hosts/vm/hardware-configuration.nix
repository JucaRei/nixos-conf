#
# Hardware settings for a general VM.
# Works on QEMU Virt-Manager and Virtualbox
#
# flake.nix
#  └─ ./hosts
#      └─ ./vm
#          └─ hardware-configuration.nix *
#
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
#

{ config, lib, pkgs, modulesPath, hostname, ... }:
let
  hostname = "teste";
in
{
  imports = [ ];

  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "ahci" "xhci_pci" "virtio_pci" "sd_mod" "sr_mod" "virtio_blk" ];
      kernelModules = [ "kvm-intel" ];
      checkJournalingFS = false; # for vm
      supportedFilesystems = [ "vfat" "btrfs" ];
      compressor = "zstd";
    };
    # kernelModules = [ "kvm-intel" "z3fold" "crc32c-intel" "lz4hc" "lz4hc_compress" "zram" ];
    kernelModules = [ "z3fold" "crc32c-intel" "lz4hc" "lz4hc_compress" "zram" ];
    extraModulePackages = [ ];

    ### Enable plymouth ###
    plymouth = {
      theme = "breeze";
      enable = true;
    };

    ### Enabled filesystem
    # supportedFilesystems = [ "vfat" "zfs" ];
    supportedFilesystems = [ "vfat" "btrfs" ];
  };

  ### Legacy Install ###
  # fileSystems."/" =
  #   {
  #     device = "/dev/disk/by-label/nixos";
  #     fsType = "ext4";
  #   };

  fileSystems."/" =
    {
      device = "/dev/disk/by-partlabel/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@root" "rw" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-partlabel/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@home" "rw" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async" ];
    };

  fileSystems."/.snapshots" =
    {
      device = "/dev/disk/by-partlabel/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" "rw" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async" ];
    };

  fileSystems."/var/tmp" =
    {
      device = "/dev/disk/by-partlabel/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@tmp" "rw" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-partlabel/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@nix" "rw" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async" ];
    };

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-partlabel/GRUB";
      fsType = "vfat";
      options = [ "defaults" "noatime" "nodiratime" ];
    };

  swapDevices = [ ];

  networking = {
    useDHCP = false; # Deprecated
    hostName = "${hostname}";
    interfaces = {
      enp1s0.useDHCP = true;
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  #virtualisation.virtualbox.guest.enable = true;     #currently disabled because package is broken
}
