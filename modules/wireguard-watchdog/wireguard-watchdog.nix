# WireGuard watchdog — restarts stale tunnels automatically.
# Checks each WireGuard interface's latest handshake every 3 minutes.
# If no handshake in 5 minutes, restarts the interface.
{ pkgs, lib, machineName, spec, ... }:
let
  registry = import ../../network/registry.nix;
  myEntry = registry.machines.${machineName};
  activeNetworks = builtins.filter (n:
    builtins.hasAttr n registry.networks
  ) (builtins.attrNames (myEntry.wg or {}));
  isGateway = spec.nodeName == "gateway";

  watchdogScript = pkgs.writeShellScript "wireguard-watchdog" ''
    set -euo pipefail
    STALE_THRESHOLD=300

    for iface in ${lib.concatStringsSep " " (map (n: "wg-${n}") activeNetworks)}; do
      if ! ip link show "$iface" &>/dev/null; then
        echo "$iface: interface missing, restarting"
        systemctl restart "wg-quick-$iface"
        continue
      fi

      latest=0
      while IFS= read -r line; do
        ts=$(echo "$line" | ${pkgs.gawk}/bin/awk '{print $NF}')
        if [ "$ts" -gt "$latest" ] 2>/dev/null; then
          latest=$ts
        fi
      done < <(${pkgs.wireguard-tools}/bin/wg show "$iface" latest-handshakes)

      if [ "$latest" -eq 0 ]; then
        echo "$iface: no handshakes ever, restarting"
        systemctl restart "wg-quick-$iface"
        continue
      fi

      now=$(date +%s)
      age=$(( now - latest ))
      if [ "$age" -gt "$STALE_THRESHOLD" ]; then
        echo "$iface: last handshake ''${age}s ago (threshold ''${STALE_THRESHOLD}s), restarting"
        systemctl restart "wg-quick-$iface"
      else
        echo "$iface: healthy (''${age}s ago)"
      fi
    done
  '';
in lib.mkIf (!isGateway && activeNetworks != []) {
  systemd.services.wireguard-watchdog = {
    description = "WireGuard tunnel watchdog";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${watchdogScript}";
    };
  };

  systemd.timers.wireguard-watchdog = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "3m";
      OnUnitActiveSec = "3m";
      Unit = "wireguard-watchdog.service";
    };
  };
}
