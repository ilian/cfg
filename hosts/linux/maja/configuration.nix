{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./vpn-gateway.nix
    ./k3s.nix
    ../../../profiles/linux/remote-unlock-tailscale.nix
    ../../../profiles/linux/systemd-boot.nix
    ../../../users/ili/linux
  ];

  # Tailscale makes the initrd large, keep the 512MiB ESP from filling up
  boot.loader.systemd-boot.configurationLimit = 5;

  # Onboard Intel I219-V NIC, for networking in the initrd
  boot.initrd.availableKernelModules = [ "e1000e" ];

  swapDevices = [ {
    device = "/var/swapfile";
    size = 8192;
  }];

  # UDP GRO settings recommended by Tailscale for exit nodes. A matching .link
  # replaces the default naming policy, so the name has to be kept explicitly.
  systemd.network.links."10-enp0s31f6" = {
    matchConfig.Path = "pci-0000:00:1f.6";
    linkConfig = {
      Name = "enp0s31f6";
      GenericReceiveOffloadUDPForwarding = true;
      GenericReceiveOffloadList = false;
    };
  };

  networking = {
    hostName = "maja";
    useNetworkd = true;
    useDHCP = false;
    interfaces.enp0s31f6.useDHCP = true;
  };
  # The initrd has no persistent DUID, use the MAC to get the same lease in both stages
  systemd.network.networks."40-enp0s31f6".dhcpV4Config.ClientIdentifier = "mac";
  boot.initrd.systemd.network.networks."40-enp0s31f6".dhcpV4Config.ClientIdentifier = "mac";

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  ili.dev.enable = false;

  nix.settings.trusted-users = [ "root" "@wheel" ];

  services.openssh.enable = true;
  programs.mosh.enable = true;

  services.tailscale = {
    openFirewall = true;
    extraSetFlags = [ "--advertise-routes=192.168.1.0/24" ];
  };

  system.stateVersion = "26.05";
}
