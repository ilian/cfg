{ pkgs, options, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/ili
  ];

  nix.trustedUsers = [ "root" "@wheel" ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  services.sshd.enable = true;

  networking.hostName = "ampere";
}
