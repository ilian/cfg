{ pkgs, lib, ... }:

{
  home = {
    packages = with pkgs; [
      # Utilities
      killall
      # System monitoring
      strace
      sysstat # iostat, sar
      bridge-utils
      ethtool
      iotop
      usbutils
    ];
  };

  programs.htop.settings = {
    show_cpu_frequency = true;
    show_cpu_temperature = true;
  };
}
