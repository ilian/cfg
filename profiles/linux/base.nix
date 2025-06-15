# Base module include by all hosts
{ pkgs, ... }:

{
  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.wheelNeedsPassword = false;

  # Takes a while to build
  # programs.bcc.enable = true;
  programs.nix-ld.enable = true;
}
