{ pkgs, ...} :

{
  services.xserver.enable = true; # optional
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.autoNumlock = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; with kdePackages; [
    ark
    kate
    okular
    filelight
    wayland-utils
  ];

  # Screensharing for Wayland session
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };
}
