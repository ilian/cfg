{ pkgs, options, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/ili
  ];

  nix.trustedUsers = [ "root" "@wheel" ];

  boot.growPartition = true;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  networking.hostName = "ampere";
}
