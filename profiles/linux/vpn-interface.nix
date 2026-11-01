# WireGuard interface of a VPN provider without any routes in the main table,
# so only traffic explicitly routed to its own table goes through the VPN. That
# table rejects traffic while the interface is missing instead of falling back
# to the uplink.
#
# The provider's wg-quick config contains secrets and is kept out of the repo at
# /etc/wireguard/wg-vpn.conf. Only its WireGuard, Address and MTU settings are
# used.
{ config, lib, pkgs, ... }:

let
  cfg = config.vpn;
  vpn = "wg-vpn";
  vpnConfig = "/etc/wireguard/${vpn}.conf";
  table = toString cfg.table;
in
{
  options.vpn = {
    table = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Routing table whose traffic goes through the VPN.";
    };

    dns = lib.mkOption {
      type = lib.types.str;
      default = "10.128.0.1";
      description = "The provider's DNS server, which is always reached through the VPN.";
    };

    sources = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "10.42.255.0/24" ];
      description = ''
        Local IPv4 subnets, such as container bridges, whose traffic to the
        internet goes through the VPN. Traffic to networks the main table has
        a more specific route for, like replies to LAN hosts, doesn't.
      '';
    };
  };

  config = {
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
        ip route replace default dev ${vpn} table ${table}
      '';
      postStop = "ip link delete ${vpn} || true";
    };

    # Not tied to the interface, so they are in place before any network comes
    # up and stay while the VPN is down
    systemd.services."${vpn}-routing" = {
      description = "Routing rules of the WireGuard VPN";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-pre.target" ];
      before = [ "network-pre.target" ];
      path = [ pkgs.iproute2 ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        rule() {
          # Rules can't be replaced, adding an existing one fails with EEXIST
          if ! out=$(ip rule add "$@" 2>&1); then
            [[ $out == *"File exists"* ]] || { echo "$out" >&2; return 1; }
          fi
        }

        ip route replace unreachable default metric 4096 table ${table}
        # From anywhere, so lookups fail instead of going out the uplink while the VPN is down
        rule priority 9500 to ${cfg.dns} table ${table}
        ${lib.concatMapStrings (source: ''
          rule priority 10001 from ${source} table main suppress_prefixlength 0
          rule priority 10002 from ${source} table ${table}
        '') cfg.sources}
      '';
    };

    # networkd would remove the rules and routes it doesn't manage itself
    systemd.network.config.networkConfig = {
      ManageForeignRoutingPolicyRules = false;
      ManageForeignRoutes = false;
    };

    # Replies arriving through the VPN come from addresses the main table routes via the uplink
    networking.firewall.checkReversePath = "loose";

    # Second layer next to the routing rule, which also holds while it is
    # missing. In the mangle table, as k3s puts filter rules accepting pod and
    # established traffic first.
    networking.firewall.extraCommands =
      let
        drop = chain: match:
          "iptables -t mangle -C ${chain} ${match} -j DROP 2>/dev/null || iptables -t mangle -I ${chain} ${match} -j DROP";
        # Keeps the TCP segments peers send to forwarded connections within
        # the interface's MTU, as path MTU discovery doesn't reliably work
        # through the VPN
        clamp = "-o ${vpn} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu";
      in
      ''
        ${drop "FORWARD" "-d ${cfg.dns} ! -o ${vpn}"}
        ${drop "OUTPUT" "-d ${cfg.dns} ! -o ${vpn}"}
        iptables -t mangle -C FORWARD ${clamp} 2>/dev/null || iptables -t mangle -I FORWARD ${clamp}
      '';
  };
}
