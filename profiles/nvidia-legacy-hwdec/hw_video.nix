{ pkgs, ... }:

{

  hardware.firmware = [ (pkgs.callPackage ./nvidia-video-firmware-legacy.nix {}) ];

  environment.systemPackages = with pkgs; [
    mesa
    libva-utils # vainfo
    vdpauinfo
  ];

  # hardware.opengl.enable = true;
  # hardware.opengl.extraPackages = with pkgs; [
  #   vaapiVdpau
  # ];

}
