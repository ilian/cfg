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
  vpn = cfg.interface;
  vpnConfig = "/etc/wireguard/${vpn}.conf";
  table = toString cfg.table;
  families = guard: lib.optional guard.ipv4 "iptables" ++ lib.optional guard.ipv6 "ip6tables";
  # The guards grouped by the table each family restores them into
  guardTables = map (t: t // {
    guards = lib.filter (guard: guard.table == t.table && lib.elem t.ipt (families guard)) cfg.guards;
  }) (lib.unique (lib.concatMap (guard:
    map (ipt: { inherit ipt; inherit (guard) table; }) (families guard)
  ) cfg.guards));
in
{
  options.vpn = {
    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg-vpn";
      readOnly = true;
      description = "The WireGuard interface.";
    };

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

    guards = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          table = lib.mkOption {
            type = lib.types.enum [ "raw" "mangle" ];
            default = "mangle";
            description = "iptables table of the rule.";
          };
          chain = lib.mkOption {
            type = lib.types.str;
            default = "FORWARD";
            description = "Built-in chain of the rule.";
          };
          match = lib.mkOption {
            type = lib.types.str;
            example = "-i enp0s31f6 -o enp0s31f6";
            description = "Matches of the packets to drop.";
          };
          ipv4 = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to drop matching IPv4 packets.";
          };
          ipv6 = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to drop matching IPv6 packets.";
          };
        };
      });
      default = [ ];
      description = ''
        Packets to drop ahead of all other firewall rules, as a second layer
        next to the routing rules, which also holds while they are missing.
        In the raw and mangle tables, as k3s puts filter rules accepting pod
        and established traffic first.
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
      before = [ "network-pre.target" "shutdown.target" ];
      conflicts = [ "shutdown.target" ];
      # Like the firewall, so networkd isn't held back until basic.target
      unitConfig.DefaultDependencies = false;
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

    # Strict, so packets with a source that is only routed via a local bridge
    # can't enter from the uplink and be relayed into the VPN
    networking.firewall.checkReversePath = true;

    vpn.guards = [
      { match = "-d ${cfg.dns} ! -o ${vpn}"; }
      { chain = "OUTPUT"; match = "-d ${cfg.dns} ! -o ${vpn}"; }
    ];

    networking.firewall.extraCommands =
      let
        # Keeps the TCP segments peers send to forwarded connections within
        # the interface's MTU, as path MTU discovery doesn't reliably work
        # through the VPN
        clamp = "-o ${vpn} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu";
      in
      ''
        # Replies arriving through the VPN come from addresses the main table routes via the uplink
        ip46tables -t mangle -I nixos-fw-rpfilter -i ${vpn} -j RETURN

        # Own chains, replaced in one transaction, so a rebuild neither adds to
        # the guards nor leaves them empty for a moment
        ${lib.concatMapStrings ({ ipt, table, guards }:
          let chains = lib.unique (map (guard: guard.chain) guards);
          in ''
            ${ipt}-restore -w -n <<'EOF'
            *${table}
            ${lib.concatMapStrings (chain: ":vpn-${chain} - [0:0]\n") chains}${lib.concatMapStrings (guard: "-A vpn-${guard.chain} ${guard.match} -j DROP\n") guards}COMMIT
            EOF
            ${lib.concatMapStringsSep "\n" (chain: "${ipt} -w -t ${table} -C ${chain} -j vpn-${chain} 2>/dev/null || ${ipt} -w -t ${table} -I ${chain} -j vpn-${chain}") chains}
          '') guardTables}

        iptables -w -t mangle -C FORWARD ${clamp} 2>/dev/null || iptables -w -t mangle -I FORWARD ${clamp}
      '';
  };
}
