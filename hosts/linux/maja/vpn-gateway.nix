# Forward traffic of LAN devices using this host as their default gateway
# through the WireGuard VPN of vpn-interface.nix. The host itself and Tailscale
# exit node traffic keep using the regular uplink. DNS has to be configured on
# the LAN devices.
{ ... }:

let
  lan = "enp0s31f6";
in
{
  imports = [ ../../../profiles/linux/vpn-interface.nix ];

  vpn.interfaces = [ lan ];

  # Never forward LAN traffic back out the LAN interface, which is also the uplink to the ISP
  vpn.guards = [ { match = "-i ${lan} -o ${lan}"; ipv6 = true; } ];

  # Redirects are sent before the firewall sees the packet and would make LAN devices bypass this host
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.send_redirects" = false;
    "net.ipv4.conf.default.send_redirects" = false;
    "net.ipv4.conf.${lan}.send_redirects" = false;
  };

  # Drop the initrd's routes, so nothing can be forwarded before the routing rules are added
  boot.initrd.network.flushBeforeStage2 = true;
}
