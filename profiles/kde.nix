{ pkgs, ...} :

{
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.autoNumlock = true;
  services.xserver.desktopManager.plasma5.enable = true;

  environment.systemPackages = with pkgs; with plasma5Packages; [
    ark
    kate
    okular
    filelight
  ];
}
