{ pkgs, options, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../profiles/linux/remote-desktop.nix
    ../../../users/ili/linux
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
