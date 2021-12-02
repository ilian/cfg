{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/audio/pipewire.nix
    ../../profiles/avahi.nix
    ../../profiles/gaming.nix
    ../../profiles/graphical.nix
    ../../profiles/grub-efi.nix
    ../../profiles/nvidia.nix
    ../../profiles/webcam.nix
    ../../users/ili
  ];

  # virtualisation.docker.enable = true;
  # networking.firewall.enable = false;

  hardware.bluetooth.enable = true;

  services.openssh.enable = true;

  networking.hostName = "kitsune";
}
