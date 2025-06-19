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
      iotop
      usbutils
    ];
  };
}
