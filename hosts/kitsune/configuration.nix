{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/grub-efi.nix
    ../../profiles/nvidia.nix
    ../../profiles/graphical.nix
    ../../profiles/gaming.nix
    ../../profiles/avahi.nix
    ../../users/ili
  ];

  # virtualisation.docker.enable = true;
  # networking.firewall.enable = false;

  services.openssh.enable = true;

  networking.hostName = "kitsune";

  environment.systemPackages = with pkgs; [
    discord
  ];
}
