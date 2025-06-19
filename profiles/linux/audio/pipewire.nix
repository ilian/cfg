{ pkgs, config, lib, ... }:

{
  hardware.pulseaudio.enable = pkgs.lib.mkForce false;

  environment.systemPackages = with pkgs; [
    easyeffects
  ];

  # musnix.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # # Use small buffer size for JACK applications to minimize latency
    # config.jack = {
    #   "jack.properties" = {
    #     "node.latency" = "128/48000";
    #   };
    # };

    # media-session.config.bluez-monitor.rules = [
    #   {
    #     # Matches all cards
    #     matches = [ { "device.name" = "~bluez_card.*"; } ];
    #     actions = {
    #       "update-props" = {
    #         "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
    #         # "bluez5.autoswitch-profile" = true;
    #       };
    #     };
    #   }
    #   {
    #     matches = [
    #       # Matches all sources
    #       { "node.name" = "~bluez_input.*"; }
    #       # Matches all outputs
    #       { "node.name" = "~bluez_output.*"; }
    #     ];
    #     actions = {
    #       "node.pause-on-idle" = false;
    #     };
    #   }
    # ];
  };

  security.rtkit.enable = true; # Used by pipewire for real-time scheduling

  # Allow applications for users in 'audio' group to use realtime scheduling
  users.extraGroups = { audio = {}; };
  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"   ; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio" ; type = "-"   ; value = "99"       ; }
    { domain = "@audio"; item = "nofile" ; type = "soft"; value = "99999"    ; }
    { domain = "@audio"; item = "nofile" ; type = "hard"; value = "99999"    ; }
  ];
}
