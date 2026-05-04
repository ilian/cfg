{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager.defaultSession = "xfce";

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "xfce4-session";
}
