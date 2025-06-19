# Base module include by all hosts
{ pkgs, ... }:

{
  imports = [
    ../common/base.nix
  ];

  nix = {
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 7d";
    };
  };
}
