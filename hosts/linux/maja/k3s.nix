# Single node k3s with flannel. Pods using the vpn RuntimeClass get a separate
# bridge, whose internet traffic vpn-gateway.nix sends through the VPN. In
# namespaces labelled egress=vpn, a label that can only be set on creation, pods
# have to use that class and can't use the host's network.
{ config, pkgs, ... }:

let
  clusterCidr = "10.42.0.0/16";
  vpnBridge = "cni-vpn";
  # Within the cluster CIDR, but outside the /24 flannel assigns to this node
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
  services.k3s = {
    enable = true;
    role = "server";
    # Unused, and each of them costs memory
    disable = [ "traefik" "servicelb" "metrics-server" ];
    # Admin kubeconfig at /etc/rancher/k3s/k3s.yaml, wheel can become root anyway
    extraFlags = [ "--write-kubeconfig-group=wheel" "--write-kubeconfig-mode=0640" ];

    manifests.vpn-egress.content = [
      {
        apiVersion = "node.k8s.io/v1";
        kind = "RuntimeClass";
        metadata.name = "vpn";
        handler = "vpn";
      }
      {
        apiVersion = "admissionregistration.k8s.io/v1";
        kind = "ValidatingAdmissionPolicy";
        metadata.name = "vpn-egress";
        spec = {
          failurePolicy = "Fail";
          matchConstraints.resourceRules = [
            {
              apiGroups = [ "" ];
              apiVersions = [ "v1" ];
              operations = [ "CREATE" ];
              resources = [ "pods" ];
            }
          ];
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
          matchResources.namespaceSelector.matchLabels.egress = "vpn";
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
              resources = [ "namespaces" ];
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
        # and any other client falls through to the VPN block after it.
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
              forward . ${config.vpnGateway.dns}
              cache 30
            }
          '';
        };
      }
    ];
  };

  # Manifests managed by hand. k3s follows symlinked directories, but stops
  # applying all manifests if one of them is missing.
  systemd.tmpfiles.settings."10-k3s-ili" = {
    "/home/ili/k8s-manifests".d = {
      user = "ili";
      group = "users";
      mode = "0750";
    };
    "/var/lib/rancher/k3s/server/manifests/ili"."L+".argument = "/home/ili/k8s-manifests";
  };

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
        isGateway = true;
        hairpinMode = true;
        ipam = {
          type = "host-local";
          ranges = [ [ { subnet = vpnPodCidr; } ] ];
          routes = [ { dst = "0.0.0.0/0"; } ];
        };
      }
      {
        type = "portmap";
        capabilities.portMappings = true;
      }
    ];
  };

  vpnGateway.networks.${vpnBridge} = vpnPodCidr;

  home-manager.users.ili = {
    programs.bash = {
      shellAliases.k = "kubectl";
      initExtra = "complete -F _complete_alias k";
    };
    # The kubectl of k3s comes without one, the script only runs kubectl itself
    xdg.dataFile."bash-completion/completions/kubectl".source = pkgs.runCommand "kubectl-completion" { } ''
      cp ${pkgs.kubectl}/share/bash-completion/completions/kubectl.bash $out
    '';
  };

  # Replies to pods arrive on the LAN interface, keep them out of the VPN gateway's table
  systemd.network.networks."40-enp0s31f6".routingPolicyRules = [
    { To = clusterCidr; Table = "main"; Priority = 9000; }
  ];

  # Pods reach the API server through the kubernetes service, which points at the host
  networking.firewall.interfaces = {
    cni0.allowedTCPPorts = [ 6443 ];
    ${vpnBridge}.allowedTCPPorts = [ 6443 ];
  };
}
