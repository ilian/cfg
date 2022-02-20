{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./audio/pipewire.nix
    ./cinnamon-xp.nix
    #./kde.nix
    #./xfce.nix
  ];

  services.xserver.enable = true;
}
