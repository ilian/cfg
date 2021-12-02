{ pkgs, config, ... }:

{
  hardware.pulseaudio.enable = pkgs.lib.mkForce false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            "bluez5.autoswitch-profile" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          { "node.name" = "~bluez_input.*"; }
          # Matches all outputs
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          "node.pause-on-idle" = false;
        };
      }
    ];
  };

  security.rtkit.enable = true; # Used by pipewire for real-time scheduling

  # Enable pulseaudio volume control to control pipewire
  environment.systemPackages =
    (if config.services.xserver.desktopManager.plasma5.enable then
    with pkgs; [ plasma-pa ]
    else
    []
    );
}
