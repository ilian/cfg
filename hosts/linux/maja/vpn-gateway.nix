# Forward traffic of LAN devices using this host as their default gateway
# through a WireGuard VPN. The host itself and Tailscale exit node traffic keep
# using the regular uplink.
#
# The provider's wg-quick config contains secrets and is kept out of the repo at
# /etc/wireguard/wg-vpn.conf. Only its WireGuard, Address and MTU settings are
# used; DNS has to be configured on the LAN devices.
{ config, lib, pkgs, ... }:

let
  cfg = config.vpnGateway;
  lan = "enp0s31f6";
  vpn = "wg-vpn";
  vpnConfig = "/etc/wireguard/${vpn}.conf";
  vpnTable = 100;
in
{
  options.vpnGateway = {
    networks = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = { cni-vpn = "10.42.255.0/24"; };
      description = ''
        Local IPv4 networks, such as container bridges, by interface name and
        subnet, whose traffic to the internet goes through the VPN. Hosts on
        them can't open connections through the uplink, not even to the LAN,
        or through Tailscale, and can't use addresses outside their subnet.
      '';
    };

    dns = lib.mkOption {
      type = lib.types.str;
      default = "10.128.0.1";
      description = "The provider's DNS server, which is always reached through the VPN.";
    };
  };

  config = {
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
        # From anywhere, so lookups fail instead of going out the uplink while the VPN is down
        { To = "${cfg.dns}/32"; Table = vpnTable; Priority = 9500; }
      ] ++ lib.concatMap (subnet: [
        # By source, as networkd holds back rules for interfaces that don't exist
        # yet. The firewall below keeps other sources off these interfaces.
        # Replies to LAN hosts and traffic to other local networks don't need the VPN.
        { From = subnet; Table = "main"; SuppressPrefixLength = 0; Priority = 10001; }
        { From = subnet; Table = vpnTable; Priority = 10002; }
      ]) (lib.attrValues cfg.networks);
      # Reject gateway traffic while the VPN is down instead of leaking it via the uplink
      routes = [
        { Destination = "0.0.0.0/0"; Type = "unreachable"; Table = vpnTable; Metric = 4096; }
      ];
    };

    networking.nat = {
      enable = true;
      internalInterfaces = [ lan ];
      # By source, as kube-router changes the packet mark NixOS uses for interfaces
      internalIPs = lib.attrValues cfg.networks;
      externalInterface = vpn;
    };

    # Replies arriving through the VPN come from addresses the main table routes via the uplink
    networking.firewall.checkReversePath = "loose";

    # Second layer next to the routing rules, which also holds while they are
    # missing: never forward LAN traffic back out the LAN interface, which is
    # also the uplink to the ISP, keep the other networks to the VPN and send
    # nothing to the provider's DNS outside of it. In the raw and mangle tables,
    # as k3s puts filter rules accepting pod and established traffic first.
    networking.firewall.extraCommands =
      let
        drop = table: chain: match:
          "$ipt -t ${table} -C ${chain} ${match} -j DROP 2>/dev/null || $ipt -t ${table} -I ${chain} ${match} -j DROP";
        tailscale = config.services.tailscale.interfaceName;
      in
      ''
        for ipt in iptables ip6tables; do
          ${lib.concatMapStringsSep "\n  " (drop "mangle" "FORWARD") (
            [ "-i ${lan} -o ${lan}" ]
            ++ lib.concatMap (iface: [
              "-i ${iface} -o ${lan} -m conntrack --ctdir ORIGINAL"
              "-i ${iface} -o ${tailscale} -m conntrack --ctdir ORIGINAL"
            ]) (lib.attrNames cfg.networks)
          )}
        done
        ipt=iptables
        ${lib.concatStringsSep "\n" (
          [
            (drop "mangle" "FORWARD" "-d ${cfg.dns} ! -o ${vpn}")
            (drop "mangle" "OUTPUT" "-d ${cfg.dns} ! -o ${vpn}")
          ]
          ++ lib.mapAttrsToList (iface: subnet: drop "raw" "PREROUTING" "-i ${iface} ! -s ${subnet}") cfg.networks
        )}
      '';

    # Redirects are sent before the firewall sees the packet and would make LAN devices bypass this host
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.send_redirects" = false;
      "net.ipv4.conf.default.send_redirects" = false;
      "net.ipv4.conf.${lan}.send_redirects" = false;
    };

    # Drop the initrd's routes, so nothing can be forwarded before networkd adds the rule
    boot.initrd.network.flushBeforeStage2 = true;
  };
}
