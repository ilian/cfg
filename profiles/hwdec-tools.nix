{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libva-utils # vainfo
    intel-gpu-tools # intel_gpu_top
  ];
}
