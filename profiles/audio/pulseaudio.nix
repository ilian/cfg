{ pkgs, config, lib, ... }:

{
  sound.enable = true;

  hardware = {
    pulseaudio = {
      support32Bit = true;
      enable = true;
      package = pkgs.pulseaudioFull;
    };
  };
}
