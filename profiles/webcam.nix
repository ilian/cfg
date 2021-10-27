{ config, pkgs, ... }:

{
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  environment.systemPackages = with pkgs; [
    guvcview
    v4l-utils
    noisetorch
    obs-studio
  ];
}
