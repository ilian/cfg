# k3s with flannel, where pods using the vpn RuntimeClass get a separate bridge
# whose traffic to the internet goes through the VPN of vpn-interface.nix. In
# namespaces labelled egress=vpn, a label that can only be set on creation,
# pods get that class, can't use the host's network and resolve names through
# the provider's DNS server.
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

  podCreations = {
    apiGroups = [ "" ];
    apiVersions = [ "v1" ];
    operations = [ "CREATE" ];
    resources = [ "pods" ];
  };
  vpnNamespaces.namespaceSelector.matchLabels.egress = "vpn";
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

  services.k3s.manifests.vpn-egress.content = [
    {
      apiVersion = "node.k8s.io/v1";
      kind = "RuntimeClass";
      metadata.name = "vpn";
      handler = "vpn";
    }
    {
      apiVersion = "admissionregistration.k8s.io/v1";
      kind = "MutatingAdmissionPolicy";
      metadata.name = "vpn-egress";
      spec = {
        failurePolicy = "Fail";
        reinvocationPolicy = "Never";
        matchConstraints.resourceRules = [ podCreations ];
        mutations = [
          {
            patchType = "ApplyConfiguration";
            applyConfiguration.expression = "Object{ spec: Object.spec{ runtimeClassName: 'vpn' } }";
          }
        ];
      };
    }
    {
      apiVersion = "admissionregistration.k8s.io/v1";
      kind = "MutatingAdmissionPolicyBinding";
      metadata.name = "vpn-egress";
      spec = {
        policyName = "vpn-egress";
        matchResources = vpnNamespaces;
      };
    }
    # Pods the mutation didn't reach, and hostNetwork pods, which have no bridge
    {
      apiVersion = "admissionregistration.k8s.io/v1";
      kind = "ValidatingAdmissionPolicy";
      metadata.name = "vpn-egress";
      spec = {
        failurePolicy = "Fail";
        matchConstraints.resourceRules = [ podCreations ];
        validations = [
          {
            expression = "has(object.spec.runtimeClassName) && object.spec.runtimeClassName == 'vpn'";
            message = "Pods in namespaces labelled egress=vpn need runtimeClassName: vpn";
          }
          {
            expression = "!has(object.spec.hostNetwork) || !object.spec.hostNetwork";
            message = "Pods in namespaces labelled egress=vpn can't use hostNetwork";
          }
        ];
      };
    }
    {
      apiVersion = "admissionregistration.k8s.io/v1";
      kind = "ValidatingAdmissionPolicyBinding";
      metadata.name = "vpn-egress";
      spec = {
        policyName = "vpn-egress";
        validationActions = [ "Deny" ];
        matchResources = vpnNamespaces;
      };
    }
    # Labelling a namespace later would leave its existing and pending pods on flannel
    {
      apiVersion = "admissionregistration.k8s.io/v1";
      kind = "ValidatingAdmissionPolicy";
      metadata.name = "egress-label";
      spec = {
        failurePolicy = "Fail";
        matchConstraints.resourceRules = [
          {
            apiGroups = [ "" ];
            apiVersions = [ "v1" ];
            operations = [ "UPDATE" ];
            # Updates through the subresources can change labels as well
            resources = [ "namespaces" "namespaces/status" "namespaces/finalize" ];
          }
        ];
        variables = [
          {
            name = "old";
            expression = "has(oldObject.metadata.labels) && 'egress' in oldObject.metadata.labels ? oldObject.metadata.labels['egress'] : ''";
          }
          {
            name = "new";
            expression = "has(object.metadata.labels) && 'egress' in object.metadata.labels ? object.metadata.labels['egress'] : ''";
          }
        ];
        validations = [
          {
            expression = "variables.old == variables.new";
            message = "The egress label can only be set when creating a namespace";
          }
        ];
      };
    }
    {
      apiVersion = "admissionregistration.k8s.io/v1";
      kind = "ValidatingAdmissionPolicyBinding";
      metadata.name = "egress-label";
      spec = {
        policyName = "egress-label";
        validationActions = [ "Deny" ];
      };
    }
    {
      apiVersion = "v1";
      kind = "ConfigMap";
      metadata = {
        name = "coredns-custom";
        namespace = "kube-system";
      };
      # Server blocks are matched top to bottom. k3s' default block, which
      # forwards to the host's resolver, is limited to pods outside the VPN
      # and any other client falls through to the block after it, a copy of
      # the default without the plugins that exist once per process.
      data = {
        "vpn.override" = ''
          view direct {
            expr !incidr(client_ip(), '${vpnPodCidr}')
          }
        '';
        "vpn.server" = ''
          .:53 {
            errors
            kubernetes cluster.local in-addr.arpa ip6.arpa {
              pods insecure
              fallthrough in-addr.arpa ip6.arpa
            }
            hosts /etc/coredns/NodeHosts {
              ttl 60
              reload 15s
              fallthrough
            }
            cache 30
            loop
            loadbalance
            forward . ${config.vpn.dns}
          }
        '';
      };
    }
  ];

  vpn.sources = [ vpnPodCidr ];

  # Pods on the VPN bridge reach the API server the same way as on cni0
  networking.firewall.interfaces.${vpnBridge}.allowedTCPPorts = [ 6443 ];

  # flannel masquerades traffic between pods unless one of them is in the
  # node's own subnet, which pods on the VPN bridge aren't. kube-proxy and the
  # portmap plugin mark the traffic they have to masquerade themselves, like a
  # pod reaching itself through a service or its host port.
  networking.firewall.extraCommands =
    let
      keep = "-s ${vpnPodCidr} -d ${vpnPodCidr} -m mark --mark 0/0x6000 -j ACCEPT";
    in
    ''
      iptables -w -t nat -C POSTROUTING ${keep} 2>/dev/null || iptables -w -t nat -I POSTROUTING ${keep}
    '';

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
