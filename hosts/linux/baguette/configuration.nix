{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../profiles/linux/remote-unlock.nix
    ../../../profiles/linux/k3s-flannel.nix
    ../../../profiles/linux/netboot-xyz-tftp.nix
    ../../../users/ili/linux
  ];

  # Boots in legacy BIOS mode
  boot.loader.grub.device = "/dev/sda";

  # Onboard Intel I350 NIC, for networking in the initrd
  boot.initrd.availableKernelModules = [ "igb" ];

  networking = {
    hostName = "baguette";
    # The default DHCP network of useDHCP matches both onboard ports, in the initrd too
    useNetworkd = true;
  };

  ili.dev.enable = false;

  nix.settings.trusted-users = [ "root" "@wheel" ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  programs.mosh.enable = true;

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
  # k3s' certificate covers the hostname, which MagicDNS resolves to the Tailscale IP
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6443 ];

  system.stateVersion = "26.05";
}
