{ pkgs, config, lib, ... }:

{
  services.pipewire.audio.enable = false;
  services.pipewire.alsa.enable = false;
  services.pipewire.pulse.enable = false;

  services.pulseaudio = {
    support32Bit = true;
    enable = true;
    package = pkgs.pulseaudioFull;
  };
}
