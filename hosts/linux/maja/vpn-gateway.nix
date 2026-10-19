# Forward traffic of LAN devices using this host as their default gateway
# through a WireGuard VPN. The host itself and Tailscale exit node traffic keep
# using the regular uplink.
#
# The provider's wg-quick config contains secrets and is kept out of the repo at
# /etc/wireguard/wg-vpn.conf. Only its WireGuard, Address and MTU settings are
# used; DNS has to be configured on the LAN devices.
{ pkgs, ... }:

let
  lan = "enp0s31f6";
  vpn = "wg-vpn";
  vpnConfig = "/etc/wireguard/${vpn}.conf";
  vpnTable = 100;
in
{
  systemd.services.${vpn} = {
    description = "WireGuard VPN for LAN gateway clients";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = vpnConfig;
    path = with pkgs; [ iproute2 wireguard-tools ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 10;
    };
    # Unlike wg-quick, only route via vpnTable instead of replacing the host's default route
    script = ''
      setting() { sed -n "s/#.*//; s/^\s*$1\s*=\s*//Ip" ${vpnConfig}; }

      ip link add ${vpn} type wireguard
      wg setconf ${vpn} <(wg-quick strip ${vpnConfig})
      for address in $(setting Address | tr , ' '); do
        # Keep provider subnets wider than /32 out of the main table
        ip address add "$address" dev ${vpn} noprefixroute
      done
      mtu=$(setting MTU)
      ip link set ${vpn} ''${mtu:+mtu $mtu} up
      ip route add default dev ${vpn} table ${toString vpnTable}
    '';
    postStop = "ip link delete ${vpn} || true";
  };

  systemd.network.networks."40-${lan}" = {
    # Evaluated after Tailscale's rules, so replies to exit node clients still reach tailscale0
    routingPolicyRules = [
      { IncomingInterface = lan; Table = vpnTable; Priority = 10000; }
    ];
    # Reject gateway traffic while the VPN is down instead of leaking it via the uplink
    routes = [
      { Destination = "0.0.0.0/0"; Type = "unreachable"; Table = vpnTable; Metric = 4096; }
    ];
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ lan ];
    externalInterface = vpn;
  };

  # Replies arriving through the VPN come from addresses the main table routes via the uplink
  networking.firewall.checkReversePath = "loose";

  # Second layer next to the routing rule: never forward LAN traffic back out
  # the LAN interface, which is also the uplink to the ISP.
  networking.firewall.extraCommands = ''
    for ipt in iptables ip6tables; do
      $ipt -C FORWARD -i ${lan} -o ${lan} -j DROP 2>/dev/null || $ipt -I FORWARD -i ${lan} -o ${lan} -j DROP
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
