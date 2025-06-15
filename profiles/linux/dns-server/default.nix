{ pkgs, config, ... }:

let
  certDir = config.security.acme.certs."mai.desu.tk".directory;
  blocklist = "/var/lib/dns-blocklist";
in

{
  systemd = {
    timers.adblock-list-renew = {
      wantedBy = [ "timers.target" ];
      partOf = [ "adblock-list-renew" ];
      timerConfig.OnCalendar = "daily";
      timerConfig.Persistent = true;
    };
    services.adblock-list-renew = {
      wantedBy = [ "kresd.target" ];
      serviceConfig.Type = "oneshot";
      script =
      let
        python = pkgs.python38.withPackages(ps: with ps; [ requests ]);
      in
      ''
        echo "Updating blocklist"
        >> ${blocklist}
        ${python}/bin/python ${./generate_blocklist.py} > ${blocklist}.new
        mv ${blocklist}.new ${blocklist}
      '';
    };
  };

  services.kresd.enable = true;
  services.kresd.extraConfig =
    ''
    modules = {
      'policy',
      'workarounds < iterate'
    }

    policy.add(
      policy.rpz(policy.DENY, '${blocklist}')
    )

    policy.add(policy.all(policy.TLS_FORWARD({
      {'1.1.1.1', hostname='cloudflare-dns.com'},
      {'1.0.0.1', hostname='cloudflare-dns.com'},
      {'9.9.9.9', hostname='dns.quad9.net'},
      {'149.112.112.112', hostname='dns.quad9.net'},
    })))
  '';

  # DoT/DoH server

  security.acme.acceptTerms = true;
  security.acme.email = "ilian@tuta.io";

  networking.firewall.allowedTCPPorts = [ 80 443 853 ];

  services.nginx = {
    enable = true;
    serverTokens = false;
    streamConfig = ''
      # DNS upstream pool
      upstream dns {
          zone dns 64k;
          server 127.0.0.1:53;
      }

      # DoT server for decryption
      server {
          listen 853 ssl;
          ssl_certificate ${certDir}/fullchain.pem;
          ssl_certificate_key ${certDir}/key.pem;
          proxy_pass dns;
      }
    '';

    virtualHosts."mai.desu.tk" = {
      forceSSL = true;
      enableACME = true;
      locations."/".extraConfig = ''
        add_header Content-Type text/plain always;
        return 200 "Hello!";
      '';
    };
  };
}
