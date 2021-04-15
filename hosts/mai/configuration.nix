{ pkgs, options, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/ili
  ];

  services.sshd.enable = true;

  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 0;

  services.cloud-init.enable = true;
  services.cloud-init.config = options.services.cloud-init.config.default + ''
    unverified_modules:
     - ssh-import-id
     - ca-certsp
  '';

  # Work around https://bugs.launchpad.net/cloud-init/+bug/1404060
  services.openssh.extraConfig = ''
    AuthorizedKeysFile .ssh/authorized_keys
  '';

  networking.hostName = "mai";
}
