{ pkgs, ... }:

{

  # Podman with docker compatibility without messing up libvirt.
  # Thankfully, podman does not load the br_netfilter kernel module
  # See: https://serverfault.com/a/964491
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
  };

  # Allow containers to resolve addresses of other containers
  # Tested with docker-compose
  virtualisation.containers.containersConf.cniPlugins = with pkgs; [
    dnsname-cni
  ];
}
