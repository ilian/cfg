{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    #./audio/pulseaudio.nix
    ./audio/pipewire.nix
    #./cinnamon-xp.nix
    #./xfce-xp.nix
    ./kde.nix
    #./xfce.nix
  ];
}
