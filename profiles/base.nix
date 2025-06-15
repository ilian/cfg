# Base module include by all hosts
{ pkgs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Amsterdam";

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    gc = {
      automatic = true;
      dates = "03:15";
      options = "--delete-older-than 7d";
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # Takes a while to build
  # programs.bcc.enable = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    n
  ];
}
