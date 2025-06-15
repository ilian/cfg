{ pkgs, ... }:
{

  # uxplay -p needed to use the ports below instead of random ones
  networking.firewall.allowedUDPPorts = [ 6000 6001 7011 ];
  networking.firewall.allowedTCPPorts = [ 7000 7001 7100 ];

  environment.systemPackages = with pkgs; [
    unstable.uxplay
  ];
}
