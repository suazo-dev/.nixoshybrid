# Darwin WireGuard app — registry-driven template generator.
{ pkgs, machineName, ... }:
let
  registry = import ../../../network/registry.nix;
  myEntry = registry.machines.${machineName};
  gwName = registry.gateway.machineName;
  gwEntry = registry.machines.${gwName};
  gwEndpoint = registry.gateway.endpoint;

  # Generate a template for each hub network this machine belongs to
  hubNetworks = builtins.filter (netName:
    builtins.hasAttr netName registry.networks
    && (registry.networks.${netName}.type or "hub") != "p2p"
  ) (builtins.attrNames (myEntry.wg or {}));

  mkTemplate = netName:
    let
      netDef = registry.networks.${netName};
      myNet = myEntry.wg.${netName};
      gwNet = gwEntry.wg.${netName};
      allowedIPs =
        if netDef.fullTunnel or false then "0.0.0.0/0, ::/0"
        else netDef.subnet;
    in
      pkgs.writeShellScriptBin "wireguard-${netName}-template" ''
        cat <<'EOF'
[Interface]
PrivateKey = <private-key>
Address = ${myNet.ip}/24

[Peer]
PublicKey = ${gwNet.publicKey}
Endpoint = ${gwEndpoint}:${toString netDef.port}
AllowedIPs = ${allowedIPs}
PersistentKeepalive = 25
EOF
      '';
in {
  homebrew.casks = [ "wireguard" ];

  environment.systemPackages = map mkTemplate hubNetworks;
}
