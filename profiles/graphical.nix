{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./audio.nix
    ./kde.nix
    #./xfce.nix
  ];

  services.xserver.enable = true;
}
