{ config, lib, pkgs, options, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../profiles/linux/remote-unlock.nix
    ../../../profiles/linux/docker.nix
    ../../../profiles/linux/k3s-flannel-vpn.nix
    ../../../profiles/linux/dnscrypt-proxy.nix
    ../../../users/ili/linux
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];

  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    kubectl
  ];

  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;

  networking.firewall.enable = true;
  # k3s API server for kubectl, its certificate covers the hostname, which MagicDNS resolves to the Tailscale IP
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6443 ];
  services.k3s.extraFlags = [ "--tls-san 100.80.57.27" ];
  networking.hostName = "ampere";

  system.stateVersion = "26.05";
}
