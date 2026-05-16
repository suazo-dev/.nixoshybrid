# Darwin WireGuard app — registry-driven template generator.
{ pkgs, machineName, ... }:
let
  registry = import ../../../network/registry.nix;
  allMachines = registry.machines;
  myEntry = allMachines.${machineName};
  gwName = registry.gateway.machineName;
  gwEntry = allMachines.${gwName};
  gwEndpoint = registry.gateway.endpoint;

  activeNetworks = builtins.filter (netName:
    builtins.hasAttr netName registry.networks
  ) (builtins.attrNames (myEntry.wg or {}));

  peerFor = netName:
    let
      netDef = registry.networks.${netName};
      isP2P = (netDef.type or "hub") == "p2p";
      peerNames = if isP2P then
        builtins.filter (name:
          name != machineName
          && builtins.hasAttr netName ((allMachines.${name}).wg or {})
        ) (builtins.attrNames allMachines)
      else
        [ gwName ];
    in
      if peerNames == [ ] then null else builtins.head peerNames;

  mkTemplate = netName:
    let
      netDef = registry.networks.${netName};
      myNet = myEntry.wg.${netName};
      peerName = peerFor netName;
      peerNet = if peerName == null then null else allMachines.${peerName}.wg.${netName};
      isP2P = (netDef.type or "hub") == "p2p";
      allowedIPs =
        if isP2P then
          if peerNet == null then "<missing-peer>/32" else "${peerNet.ip}/32"
        else if netDef.fullTunnel or false then
          "0.0.0.0/0, ::/0"
        else
          builtins.concatStringsSep ", " ([ netDef.subnet ] ++ (netDef.extraAllowedIPs or [ ]));
      endpointLine =
        if peerNet != null && peerNet ? endpoint then
          "Endpoint = ${peerNet.endpoint}"
        else if !isP2P then
          "Endpoint = ${gwEndpoint}:${toString netDef.port}"
        else
          "# Endpoint = <set-peer-endpoint>";
      publicKey = if peerNet == null then "<missing-peer>" else peerNet.publicKey;
    in
      pkgs.writeShellScriptBin "wireguard-${netName}-template" ''
        cat <<'EOF'
[Interface]
PrivateKey = <private-key>
Address = ${myNet.ip}/24

[Peer]
PublicKey = ${publicKey}
${endpointLine}
AllowedIPs = ${allowedIPs}
PersistentKeepalive = 25
EOF
      '';
in {
  environment.systemPackages = map mkTemplate activeNetworks;
}
