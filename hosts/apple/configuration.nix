{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/grub-efi.nix
    ../../profiles/laptop.nix
    ../../profiles/graphical.nix
    ../../profiles/gaming.nix
    ../../profiles/avahi.nix
    ../../users/ili
  ];

  boot.kernelParams = [
    # https://wiki.archlinux.org/index.php/Apple_Keyboard
    "hid_apple.iso_layout=0" # Map backtick below escape
    "hid_apple.swap_opt_cmd=1" # Swap alt and command keys
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

  services.openssh.enable = true;

  networking.hostName = "apple";
}
