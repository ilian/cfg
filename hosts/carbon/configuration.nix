{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/grub-efi.nix
    ../../profiles/laptop.nix
    ../../profiles/graphical.nix
    ../../profiles/avahi.nix
    ../../profiles/udev.nix
    ../../users/ili
  ];

  networking.hostName = "carbon";
}
