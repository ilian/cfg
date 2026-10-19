# Unlock disk encryption remotely by SSH from the initrd, reachable on the LAN
# and through a separate Tailscale node that only runs during stage 1.
#
# Before installing, generate the initrd's SSH host key. It ends up unencrypted
# on /boot, so it must not be the system's host key:
#   mkdir -p /mnt/etc/secrets/initrd/tailscale
#   ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key
#
# After the first boot, log in the initrd's Tailscale node with a temporary
# second tailscaled, disable its key expiry in the admin console and run
# `nixos-rebuild boot` to add its state to the initrd:
#   sudo tailscaled --tun=userspace-networking --port=0 \
#     --statedir=/etc/secrets/initrd/tailscale --socket=/run/tailscale-initrd.sock
#   sudo tailscale --socket=/run/tailscale-initrd.sock up --hostname=$(hostname)-initrd
#
# Unlock with `ssh -p 2222 root@<hostname>-initrd`.
{ config, pkgs, ... }:

let
  # The wrapper only adds tools to PATH that userspace networking doesn't need
  tailscaled = "${pkgs.tailscale}/bin/.tailscaled-wrapped";
  caBundle = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
in
{
  boot.initrd.systemd.enable = true;
  boot.initrd.network.enable = true;

  boot.initrd.network.ssh = {
    enable = true;
    # Avoid known_hosts conflicts with the system's SSH server on the same IP
    port = 2222;
    hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    authorizedKeyFiles = config.users.users.ili.openssh.authorizedKeys.keyFiles;
  };
  boot.initrd.systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";

  boot.initrd.secrets."/var/lib/tailscale" = "/etc/secrets/initrd/tailscale";
  boot.initrd.systemd.storePaths = [ tailscaled caBundle ];
  boot.initrd.systemd.services.tailscaled = {
    description = "Tailscale node for remote unlocking";
    wantedBy = [ "initrd.target" ];
    after = [ "network.target" "initrd-nixos-copy-secrets.service" ];
    before = [ "shutdown.target" ];
    conflicts = [ "shutdown.target" ];
    unitConfig = {
      DefaultDependencies = false;
      ConditionPathExists = "/var/lib/tailscale/tailscaled.state";
    };
    # Userspace networking forwards connections to the node's Tailscale IP to
    # localhost, so neither TUN nor iptables are needed in the initrd.
    serviceConfig = {
      ExecStart = "${tailscaled} --tun=userspace-networking --statedir=/var/lib/tailscale";
      Environment = "SSL_CERT_FILE=${caBundle}";
      Restart = "on-failure";
    };
  };
}
