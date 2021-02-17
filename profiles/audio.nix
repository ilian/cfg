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

  ## PIPEWIRE
  ## hardware.pulseaudio.enable = pkgs.lib.mkForce false;
  ## services.pipewire = {
  ##   enable = true;
  ##   alsa.enable = true;
  ##   alsa.support32Bit = true;
  ##   pulse.enable = true;
  ##   jack.enable = true;
  ## };
  ## security.rtkit.enable = true; # Used by pipewire for real-time scheduling

  ##  # Enable pulseaudio volume control to control pipewire
  ##  environment.systemPackages =
  ##    (if config.services.xserver.desktopManager.plasma5.enable then
  ##       with pkgs; [ plasma-pa ]
  ##     else
  ##       []
  ##    );

}
