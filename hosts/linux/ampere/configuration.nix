{ pkgs, options, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../profiles/linux/docker.nix
    ../../../profiles/linux/remote-desktop.nix
    ../../../users/ili/linux
  ];

  boot.growPartition = true;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];

  programs.mosh.enable = true;
  services.tailscale.enable = true;

  # Install cilium after creating a k3s cluster:
  # cilium install --version 1.19.0 --set=ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16"
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
     "--tls-san 100.80.57.27"
     # Cilium
     "--disable=traefik,flannel"
     "--flannel-backend=none"
     "--disable-network-policy"
     "--disable-kube-proxy"
     "--disable-cloud-controller"
    ];
  };

  networking.firewall = {
    enable = true;

    extraCommands = ''
      iptables -A INPUT -s 10.42.0.0/16 -j ACCEPT # Cilium
    '';

    checkReversePath = false; # Cilium
  };

  environment.systemPackages = with pkgs; [
    kubectl
    cilium-cli
  ];

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  networking.hostName = "ampere";

  system.stateVersion = "22.11";
}
