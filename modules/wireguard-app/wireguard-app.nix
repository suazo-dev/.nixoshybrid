# Darwin WireGuard — registry-driven, wg-quick + launchd.
#
# Private key setup (one-time, for each active network on the machine):
#   sudo mkdir -p /etc/wireguard && sudo chmod 700 /etc/wireguard
#   echo '<private-key>' | sudo tee /etc/wireguard/core.key    > /dev/null
#   sudo chmod 400 /etc/wireguard/*.key
#
# The daemon writes the conf from the key on every start, then brings the
# tunnel up. No activation script required.
#
# To restart a tunnel manually:
#   sudo launchctl kickstart -k system/org.nixos.wireguard-core
{ pkgs, lib, machineName, ... }:
let
  registry = import ../../network/registry.nix;
  myEntry = registry.machines.${machineName};
  gwName = registry.gateway.machineName;
  gwEndpoint = registry.gateway.endpoint;
  allMachines = registry.machines;

  activeNetworks = builtins.filter (n: builtins.hasAttr n registry.networks)
    (builtins.attrNames (myEntry.wg or {}));

  subnetMask = subnet: builtins.elemAt (lib.splitString "/" subnet) 1;

  mkNet = netName:
    let
      netDef = registry.networks.${netName};
      myNet = myEntry.wg.${netName};
      isP2P = (netDef.type or "hub") == "p2p";
      fullTunnel = !isP2P && (netDef.fullTunnel or false);

      peerName =
        if isP2P then
          let ps = builtins.filter (n:
            n != machineName
            && builtins.hasAttr netName ((allMachines.${n}).wg or {})
          ) (builtins.attrNames allMachines);
          in if ps == [] then null else builtins.head ps
        else gwName;

      peerNet =
        if peerName != null then allMachines.${peerName}.wg.${netName}
        else null;

      allowedIPs =
        if isP2P then
          if peerNet != null then "${peerNet.ip}/32" else "0.0.0.0/32"
        else if fullTunnel then
          "0.0.0.0/0, ::/0"
        else
          builtins.concatStringsSep ", "
            ([ netDef.subnet ] ++ (netDef.extraAllowedIPs or []));

      endpoint =
        if peerNet != null && peerNet ? endpoint then peerNet.endpoint
        else if !isP2P then "${gwEndpoint}:${toString netDef.port}"
        else null;
    in {
      name = netName;
      keyPath = "/etc/wireguard/${netName}.key";
      confPath = "/etc/wireguard/${netName}.conf";
      address = "${myNet.ip}/${subnetMask netDef.subnet}";
      publicKey = if peerNet != null then peerNet.publicKey else "<missing-peer>";
      inherit allowedIPs endpoint fullTunnel;
    };

  nets = map mkNet activeNetworks;

  wgTools = "${pkgs.wireguard-tools}/bin";
  wgGo = "${pkgs.wireguard-go}/bin";

  mkDaemon = net:
    let
      dnsLine = lib.optionalString net.fullTunnel "\nDNS = 1.1.1.1";
      endpointLine = lib.optionalString (net.endpoint != null) "\nEndpoint = ${net.endpoint}";
    in
    lib.nameValuePair "wireguard-${net.name}" {
      script = ''
        export PATH=${wgTools}:${wgGo}:/usr/bin:/bin:/usr/sbin:/sbin

        KEY=${lib.escapeShellArg net.keyPath}
        CONF=${lib.escapeShellArg net.confPath}

        if [ ! -f "$KEY" ]; then
          echo "wireguard-${net.name}: key not found at $KEY — place key and restart" >&2
          exit 0
        fi

        PRIV=$(cat "$KEY")

        /bin/mkdir -p /etc/wireguard
        /bin/chmod 700 /etc/wireguard

        cat > "$CONF" << WGEOF
        [Interface]
        PrivateKey = $PRIV
        Address = ${net.address}${dnsLine}

        [Peer]
        PublicKey = ${net.publicKey}${endpointLine}
        AllowedIPs = ${net.allowedIPs}
        PersistentKeepalive = 25
        WGEOF

        /bin/chmod 600 "$CONF"

        # Clean up any stale tunnel from a previous run.
        wg-quick down "$CONF" 2>/dev/null || true

        if ! wg-quick up "$CONF"; then
          echo "wireguard-${net.name}: wg-quick up failed" >&2
          exit 1
        fi

        echo "wireguard-${net.name}: tunnel up"

        # Stay alive — wireguard-go manages the tunnel independently.
        # KeepAlive=true will restart this script if it exits unexpectedly.
        while true; do sleep 86400; done
      '';
      serviceConfig = {
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/var/log/wireguard-${net.name}.log";
        StandardErrorPath = "/var/log/wireguard-${net.name}.log";
      };
    };

in {
  environment.systemPackages = with pkgs; [ wireguard-tools wireguard-go ];

  launchd.daemons = lib.listToAttrs (map mkDaemon nets);
}
