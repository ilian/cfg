{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./audio/pipewire.nix
    ./kde.nix
    #./xfce.nix
  ];

  services.xserver.enable = true;
}
