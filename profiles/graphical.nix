{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./audio.nix
    ./kde.nix
    #./xfce.nix
  ];

  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
    mpv
  ];
}
