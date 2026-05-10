# DuckDNS module — registry-driven.
# Only activates on the gateway machine.
{ pkgs, lib, spec, machineName, config, ... }:
let
  registry = import ../../../network/registry.nix;
  isGateway = machineName == registry.gateway.machineName;
  duckdnsDomain = "${registry.gateway.duckdnsDomain}.duckdns.org";

  updateScript = pkgs.writeShellScript "duckdns-update" ''
    set -euo pipefail
    DOMAIN="${duckdnsDomain}"
    TOKEN="$(tr -d '\n' < ${config.sops.secrets."duckdns/token".path})"
    RESPONSE="$(${pkgs.curl}/bin/curl -fsS \
      --retry 3 \
      --retry-delay 2 \
      --connect-timeout 10 \
      --max-time 30 \
      "https://www.duckdns.org/update?domains=''${DOMAIN%%.duckdns.org}&token=$TOKEN&ip=")"

    if [ "$RESPONSE" != "OK" ]; then
      printf 'DuckDNS update failed: %s\n' "$RESPONSE" >&2
      exit 1
    fi
  '';
in
{
  sops.secrets."duckdns/token" = lib.mkIf isGateway {
    owner = "root";
    group = "root";
    mode = "0400";
    path = "/run/secrets/duckdns-token";
  };

  systemd.services.duckdns-update = lib.mkIf isGateway {
    description = "Update DuckDNS";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${updateScript}";
    };
  };

  systemd.timers.duckdns-update = lib.mkIf isGateway {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2m";
      OnUnitActiveSec = "5m";
      Unit = "duckdns-update.service";
    };
  };
}
