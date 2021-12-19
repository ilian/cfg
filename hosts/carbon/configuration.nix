{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/avahi.nix
    ../../profiles/graphical.nix
    ../../profiles/grub-efi.nix
    ../../profiles/hwdec-tools.nix
    ../../profiles/laptop.nix
    ../../profiles/libvirt.nix
    ../../profiles/udev.nix
    ../../users/ili
  ];

  networking.hostName = "carbon";
}
