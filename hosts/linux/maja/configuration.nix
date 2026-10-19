{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./vpn-gateway.nix
    ../../../profiles/linux/remote-unlock.nix
    ../../../profiles/linux/systemd-boot.nix
    ../../../users/ili/linux
  ];

  # Tailscale makes the initrd large, keep the 512MiB ESP from filling up
  boot.loader.systemd-boot.configurationLimit = 5;

  # Onboard Intel I219-V NIC, for networking in the initrd
  boot.initrd.availableKernelModules = [ "e1000e" ];

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

  nix.settings.trusted-users = [ "root" "@wheel" ];

  services.openssh.enable = true;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-exit-node" ];
  };

  system.stateVersion = "26.05";
}
