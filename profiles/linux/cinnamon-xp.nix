{ pkgs, ... }:

{
  services.xserver.desktopManager.cinnamon.enable = true;
  environment.systemPackages = with pkgs; [
    gettext # Required for custom applets to be installed
    libgtop # System Monitor applet
    redshift
    cinnxp # XP Theme
    okular # KDE document viewer
  ];
}
