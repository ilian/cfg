{ pkgs, options, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/ili
  ];

  swapDevices = [ {
    device = "/var/swapfile";
    size = 4096;
  }];

  nix.trustedUsers = [ "root" "@wheel" ];

  services.borgbackup.repos.ili = {
    path = "/var/lib/borgbackup";
    authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILwMKH6WfYYP3vF52y1lgZedgPhl3POHhI1ASm7qkU5q work" ];
  };

  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 0;

  services.openssh.enable = true;

  networking.hostName = "mai";
}
