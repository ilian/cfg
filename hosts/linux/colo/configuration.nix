{ ... }:

let
  network = {
    netdevs."10-bond0" = {
      netdevConfig = {
        Kind = "bond";
        Name = "bond0";
      };
      bondConfig = {
        Mode = "802.3ad";
        TransmitHashPolicy = "layer3+4";
        MIIMonitorSec = "100ms";
      };
    };
    networks."30-bond0-ports" = {
      matchConfig.Name = "enp59s0f0np0 enp59s0f1np1";
      networkConfig.Bond = "bond0";
      linkConfig.MTUBytes = "9000";
    };
    networks."40-bond0" = {
      matchConfig.Name = "bond0";
      address = [ "100.127.22.2/23" ];
      gateway = [ "100.127.22.1" ];
      dns = [ "1.1.1.1" "1.0.0.1" ];
      # Edge loopbacks
      ntp = [ "100.127.30.1" "100.127.30.2" ];
      linkConfig = {
        MTUBytes = "9000";
        RequiredForOnline = "routable";
      };
    };
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../../profiles/linux/systemd-boot.nix
    ../../../profiles/linux/docker.nix
    ../../../users/ili/linux
  ];

  networking = {
    hostName = "colo";
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network = { inherit (network) netdevs networks; };

  nix.settings.trusted-users = [ "root" "@wheel" ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  programs.mosh.enable = true;

  system.stateVersion = "26.05";
}
