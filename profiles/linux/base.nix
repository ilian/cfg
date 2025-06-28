# Base module include by all hosts
{ pkgs, ... }:

{

  imports = [
    ../common/base.nix
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "03:15";
      options = "--delete-older-than 7d";
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.wheelNeedsPassword = false;

  # Takes a while to build
  # programs.bcc.enable = true;
  programs.nix-ld.enable = true;
}
