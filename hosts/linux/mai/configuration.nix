{ pkgs, options, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../users/ili/linux
  ];

  # Taken from /proc/cmdline of Ubuntu 20.04.2 LTS on OCI
  boot.kernelParams = [
    "console=tty1"
    "console=ttyS0"
    "nvme.shutdown_timeout=10"
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"
  ];

  swapDevices = [ {
    device = "/var/swapfile";
    size = 4096;
  }];

  nix.settings.trusted-users = [ "root" "@wheel" ];

  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 10;
  boot.loader.timeout = 0;

  services.openssh.enable = true;

  networking.hostName = "mai";

  # Preserve defaults from when this host was first configured.
  system.stateVersion = "26.05";
}
