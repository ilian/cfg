# Forward traffic of LAN devices using this host as their default gateway
# through the WireGuard VPN of vpn-interface.nix. The host itself and Tailscale
# exit node traffic keep using the regular uplink. DNS has to be configured on
# the LAN devices.
{ config, ... }:

let
  lan = "enp0s31f6";
  vpn = "wg-vpn";
in
{
  imports = [ ../../../profiles/linux/vpn-interface.nix ];

  systemd.network.networks."40-${lan}".routingPolicyRules = [
    # Replies to pods arrive on the LAN interface, keep them out of the VPN's table
    { To = "10.42.0.0/16"; Table = "main"; Priority = 9000; }
    # Evaluated after Tailscale's rules, so replies to exit node clients still reach tailscale0
    { IncomingInterface = lan; Table = config.vpn.table; Priority = 10000; }
  ];

  networking.nat = {
    enable = true;
    internalInterfaces = [ lan ];
    externalInterface = vpn;
  };

  # Second layer next to the routing rule, which also holds while it is
  # missing: never forward LAN traffic back out the LAN interface, which is
  # also the uplink to the ISP. In the mangle table, as k3s puts filter rules
  # accepting pod and established traffic first.
  networking.firewall.extraCommands = ''
    for ipt in iptables ip6tables; do
      $ipt -t mangle -C FORWARD -i ${lan} -o ${lan} -j DROP 2>/dev/null || $ipt -t mangle -I FORWARD -i ${lan} -o ${lan} -j DROP
    done
  '';

  # Redirects are sent before the firewall sees the packet and would make LAN devices bypass this host
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.send_redirects" = false;
    "net.ipv4.conf.default.send_redirects" = false;
    "net.ipv4.conf.${lan}.send_redirects" = false;
  };

  # Drop the initrd's routes, so nothing can be forwarded before networkd adds the rule
  boot.initrd.network.flushBeforeStage2 = true;
}
