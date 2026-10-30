# Manifests in /home/ili/k8s-manifests are applied next to the ones from Nix.
# They are synced from ~/k8s/<host> on patatje by ~/k8s/sync.
{ ... }:

{
  # k3s follows symlinked directories, but stops applying all manifests if one
  # of them is missing.
  systemd.tmpfiles.settings."10-k3s-ili" = {
    "/home/ili/k8s-manifests".d = {
      user = "ili";
      group = "users";
      mode = "0750";
    };
    "/var/lib/rancher/k3s/server/manifests/ili"."L+".argument = "/home/ili/k8s-manifests";
  };
}
