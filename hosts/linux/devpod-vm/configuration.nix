{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../profiles/linux/remote-unlock-tailscale.nix
    ../../../profiles/linux/systemd-boot.nix
    ../../../users/ili/linux
  ];

  # Tailscale makes the initrd large, keep the 512MiB ESP from filling up
  boot.loader.systemd-boot.configurationLimit = 5;

  # The console the pod attaches to, also for the passphrase prompt
  boot.kernelParams = [ "console=ttyS0,115200" ];

  networking = {
    hostName = "devpod-vm";
    useNetworkd = true;
    useDHCP = false;
  };
  # The VM's one NIC, on QEMU's user networking, in both stages
  systemd.network.networks."40-uplink" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "yes";
  };
  boot.initrd.systemd.network.networks."40-uplink" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "yes";
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];

  services.openssh.enable = true;
  programs.mosh.enable = true;

  system.stateVersion = "26.05";
}
