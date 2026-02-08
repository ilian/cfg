{ pkgs, ...} :

{
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
    extraCommands = ''
      iptables -A INPUT -s 10.42.0.0/16 -j ACCEPT # Cilium
    '';

    checkReversePath = false; # Cilium
  };

  environment.systemPackages = with pkgs; [
    kubectl
    cilium-cli
  ];
}
