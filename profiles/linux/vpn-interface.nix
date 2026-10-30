# WireGuard interface of a VPN provider without any routes, so only traffic
# explicitly routed to it goes through the VPN.
#
# The provider's wg-quick config contains secrets and is kept out of the repo at
# /etc/wireguard/wg-vpn.conf. Only its WireGuard, Address and MTU settings are
# used.
{ pkgs, ... }:

let
  vpn = "wg-vpn";
  vpnConfig = "/etc/wireguard/${vpn}.conf";
in
{
  systemd.services.${vpn} = {
    description = "WireGuard VPN";
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
    '';
    postStop = "ip link delete ${vpn} || true";
  };
}
