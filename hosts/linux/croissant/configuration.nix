{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ../../../profiles/linux/remote-unlock-tailscale.nix
    ../../../profiles/linux/k3s-flannel-vpn.nix
    ../../../users/ili/linux
  ];

  # Without touching the EFI variables, systemd-boot is booted from the
  # fallback path, and the provider's network boot into its rescue system stays
  # first in the boot order
  boot.loader.systemd-boot = {
    enable = true;
    # Tailscale makes the initrd large, keep the 1GiB ESP from filling up
    configurationLimit = 10;
  };

  # Intel NIC, for networking in the initrd
  boot.initrd.availableKernelModules = [ "igb" ];

  powerManagement.cpuFreqGovernor = "performance";

  networking = {
    hostName = "croissant";
    # The default DHCP network of useDHCP matches the NIC's ports, in the initrd too
    useNetworkd = true;
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  programs.mosh.enable = true;

  services.tailscale.openFirewall = true;
  # k3s' certificate covers the hostname, which MagicDNS resolves to the Tailscale IP
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6443 ];

  system.stateVersion = "26.05";
}
