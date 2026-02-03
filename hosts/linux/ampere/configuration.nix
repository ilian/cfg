{ pkgs, options, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../profiles/linux/remote-desktop.nix
    ../../../users/ili/linux
  ];

  boot.growPartition = true;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  nix.settings.trustedUsers = [ "root" "@wheel" ];
  programs.mosh.enable = true;

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  networking.hostName = "ampere";

  system.stateVersion = "22.11";
}
