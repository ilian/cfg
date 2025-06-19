{ pkgs, config, lib, ... }:

{
  services.pipewire.audio.enable = false;
  services.pipewire.alsa.enable = false;
  services.pipewire.pulse.enable = false;

  hardware = {
    pulseaudio = {
      support32Bit = true;
      enable = true;
      package = pkgs.pulseaudioFull;
    };
  };
}
