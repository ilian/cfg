{ pkgs, options, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/ili
  ];

  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 0;

  services.sshd.enable = true;

  networking.hostName = "mai";
}
