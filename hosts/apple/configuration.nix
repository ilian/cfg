{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/ili
    ../../profiles/laptop.nix
    ../../profiles/graphical.nix
    ../../profiles/gaming.nix
  ];

  # boot.kernelPackages = pkgs.linuxPackages_5_10;

  # NVIDIA
  # boot.initrd.extraUtilsCommands = ''
  #   copy_bin_and_libs ${pkgs.pciutils}/bin/setpci
  # '';
  # boot.initrd.postDeviceCommands = ''
  #   setpci -s "00:17.0" 3e.b=8;
  #   setpci -s "02:00.0" 04.b=7;
  # '';
  # services.xserver.videoDrivers = [ "nvidiaLegacy340" ];

  # services.xserver.deviceSection = ''
  #   Option   "DPI"             "96 x 96"
  #   Option   "RegistryDwords"  "EnableBrightnessControl=1"
  # '';

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  services.sshd.enable = true;

  networking.hostName = "apple";
}
