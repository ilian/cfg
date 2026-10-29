# netboot.xyz for arm64 UEFI over TFTP, to rescue machines that can't boot
# from the network otherwise, like Oracle Cloud's Ampere instances. From the
# UEFI shell, reached through the serial console:
#   ifconfig -s eth0 dhcp
#   fs0:
#   tftp -s 1400 <IPv4 address of this host> netboot.xyz-arm64-snp.efi
#   netboot.xyz-arm64-snp.efi
{ pkgs, ... }:

let
  version = "3.0.3";
  # The SNP build uses the firmware's network driver, like the shell's tftp
  tftpRoot = pkgs.linkFarm "netboot.xyz-tftp" {
    "netboot.xyz-arm64-snp.efi" = pkgs.fetchurl {
      url = "https://github.com/netbootxyz/netboot.xyz/releases/download/${version}/netboot.xyz-arm64-snp.efi";
      hash = "sha256-gryNhQbaljKpNwlFTZdKAH6Votq418ErAX/PNBlQY74=";
    };
  };
in
{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      # TFTP only
      port = 0;
      enable-tftp = true;
      tftp-root = "${tftpRoot}";
      # Sending data from another port than the request went to wouldn't match
      # the connection a stateful firewall or NAT in front of the client, such
      # as Oracle Cloud's security lists, has seen going out
      tftp-single-port = true;
    };
  };

  networking.firewall.allowedUDPPorts = [ 69 ];
}
