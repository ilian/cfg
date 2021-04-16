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
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    n
  ];
}
