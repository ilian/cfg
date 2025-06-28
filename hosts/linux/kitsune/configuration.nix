{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../profiles/linux/avahi.nix
    ../../../profiles/linux/gaming.nix
    ../../../profiles/linux/graphical.nix
    ../../../profiles/linux/grub-efi.nix
    ../../../profiles/linux/nvidia.nix
    ../../../profiles/linux/obs-webcam.nix
    ../../../users/ili/linux
  ];

  # virtualisation.docker.enable = true;
  # networking.firewall.enable = false;

  hardware.bluetooth.enable = true;

  services.openssh.enable = true;

  networking.hostName = "kitsune";
}
