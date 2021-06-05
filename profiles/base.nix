# Base module include by all hosts
{ pkgs, ...}:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Amsterdam";

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "03:15";
      options = "--delete-older-than 7d";
    };
  };

  security.sudo.wheelNeedsPassword = false;

  programs.bcc.enable = true;

  environment.systemPackages = with pkgs; [
    n
  ];
}
