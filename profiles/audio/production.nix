{ pkgs, config, ...}:

{
  sound.enable = true;
  musnix.enable = true;

  # Eliminate XRUNs
  boot.kernelPackages = pkgs.linuxPackages-rt;

  environment.systemPackages = with pkgs; [
    qjackctl libjack2 jack2
    real_time_config_quick_scan

    reaper
    pianoteq
  ];

  hardware = {
    pulseaudio = {
      support32Bit = true;
      enable = true;
      package = pkgs.pulseaudioFull;
    };
  };
}
