# Base module include by all hosts
{ config, lib, pkgs, ... }:

{

  imports = [
    ../common/base.nix
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "03:15";
      options = "--delete-older-than 7d";
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.wheelNeedsPassword = false;

  # Takes a while to build
  # programs.bcc.enable = true;
  programs.nix-ld.enable = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-exit-node" ];
    extraDaemonFlags = [ "--no-logs-no-support" ];
  };

  # SSH and mosh only through Tailscale. Hosts the internet can't reach open
  # them on every interface with openFirewall.
  services.openssh.openFirewall = lib.mkDefault false;
  programs.mosh.openFirewall = lib.mkDefault false;
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = lib.optionals config.services.openssh.enable config.services.openssh.ports;
    allowedUDPPortRanges = lib.optional config.programs.mosh.enable { from = 60000; to = 61000; };
  };
}
