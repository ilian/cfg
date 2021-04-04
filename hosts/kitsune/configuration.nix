{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/ili
    ../../profiles/nvidia.nix
    ../../profiles/graphical.nix
    ../../profiles/gaming.nix
    ../../profiles/avahi.nix
  ];

  # virtualisation.docker.enable = true;
  # networking.firewall.enable = false;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  services.sshd.enable = true;

  networking.hostName = "kitsune";

  environment.systemPackages = with pkgs; [
    discord
  ];

}
