# Single node k3s with flannel. Manifests in /home/ili/k8s-manifests are applied
# next to the ones from Nix.
{ pkgs, ... }:

{
  services.k3s = {
    enable = true;
    role = "server";
    # Unused, and each of them costs memory
    disable = [ "traefik" "servicelb" "metrics-server" ];
    # Admin kubeconfig at /etc/rancher/k3s/k3s.yaml, wheel can become root anyway
    extraFlags = [ "--write-kubeconfig-group=wheel" "--write-kubeconfig-mode=0640" ];
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

  # Pods reach the API server through the kubernetes service, which points at the host
  networking.firewall.interfaces.cni0.allowedTCPPorts = [ 6443 ];
}
