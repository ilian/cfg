# k3s with flannel, where pods using the vpn RuntimeClass get a separate bridge
# whose traffic to the internet goes through the VPN of vpn-interface.nix. The
# RuntimeClass, the admission policies assigning it to pods in namespaces
# labelled egress=vpn and the DNS setup for those pods are manifests in
# ~/k8s/<host>/vpn.
{ config, pkgs, ... }:

let
  clusterCidr = "10.42.0.0/16";
  vpnBridge = "cni-vpn";
  # Within the cluster CIDR, so kube-proxy and flannel treat it as pods, but
  # outside the /24 flannel assigns to this node
  vpnPodCidr = "10.42.255.0/24";
  vpnCniConfDir = "/etc/cni/vpn.d";

  # containerd selects the network config per runtime, so the RuntimeClass decides the bridge
  containerdTemplate = pkgs.writeText "config-v3.toml.tmpl" ''
    {{ template "base" . }}

    [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.vpn]
      runtime_type = "io.containerd.runc.v2"
      cni_conf_dir = "${vpnCniConfDir}"

    [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.vpn.options]
      SystemdCgroup = {{ .SystemdCgroup }}
  '';
in
{
  imports = [
    ./k3s-flannel.nix
    ./vpn-interface.nix
  ];

  # k3s' default, pinned as the bridge subnet and guards depend on it
  services.k3s.extraFlags = [ "--cluster-cidr=${clusterCidr}" ];

  # k3s reads templates in containerd 2 syntax from the -v3 name, NixOS'
  # containerdConfigTemplate writes the older one. Linking it here also
  # restarts k3s on changes.
  systemd.services.k3s.preStart = ''
    mkdir -p /var/lib/rancher/k3s/agent/etc/containerd
    ln -sfn ${containerdTemplate} /var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.tmpl
  '';

  environment.etc."cni/vpn.d/10-vpn.conflist".text = builtins.toJSON {
    cniVersion = "1.0.0";
    name = "vpn";
    plugins = [
      {
        type = "bridge";
        bridge = vpnBridge;
        isDefaultGateway = true;
        hairpinMode = true;
        ipam = {
          type = "host-local";
          ranges = [ [ { subnet = vpnPodCidr; } ] ];
        };
      }
      {
        type = "portmap";
        capabilities.portMappings = true;
      }
    ];
  };

  vpn.sources = [ vpnPodCidr ];

  # Pods on the VPN bridge reach the API server the same way as on cni0
  networking.firewall.interfaces.${vpnBridge}.allowedTCPPorts = [ 6443 ];

  # Pods on the VPN bridge only open connections to the cluster and, through
  # the VPN, the internet, and only from their own subnet. Packets without a
  # connection have no direction to match.
  vpn.guards = [
    { table = "raw"; chain = "PREROUTING"; match = "-i ${vpnBridge} ! -s ${vpnPodCidr}"; }
    { match = "-i ${vpnBridge} ! -o ${config.vpn.interface} ! -d ${clusterCidr} -m conntrack --ctdir ORIGINAL"; }
    { match = "-i ${vpnBridge} -m conntrack --ctstate INVALID,UNTRACKED"; }
    { match = "-i ${vpnBridge}"; ipv4 = false; ipv6 = true; }
  ];
}
