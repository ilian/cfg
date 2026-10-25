# Unlock disk encryption remotely by SSH from the initrd.
#
# Before installing, generate the initrd's SSH host key. It ends up unencrypted
# on /boot, so it must not be the system's host key:
#   mkdir -p /mnt/etc/secrets/initrd
#   ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key
#
# Unlock with `ssh -p 2222 root@<hostname>`.
{ config, ... }:

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
}
