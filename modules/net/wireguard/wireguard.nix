# WireGuard module — fully registry-driven.
# No machine names, IPs, keys, or ports in this file.
# Everything derived from network/registry.nix.
{
  config,
  lib,
  machineName,
  spec,
  ...
}: let
  registry = import ../../../network/registry.nix;
  gwName = registry.gateway.machineName;
  gwEndpoint = registry.gateway.endpoint;
  myEntry = registry.machines.${machineName};
  gwEntry = registry.machines.${gwName};
  hasRole = role: builtins.elem role spec.roles;
  isGateway = machineName == gwName;

  subnetMask = subnet: builtins.elemAt (lib.splitString "/" subnet) 1;

  mkSecret = secretName: {
    owner = "root";
    group = "root";
    mode = "0400";
    path = "/run/secrets/wireguard/${secretName}.key";
  };

  # Networks this machine participates in
  myNetworks = builtins.attrNames (myEntry.wg or {});
  activeNetworks = builtins.filter (n: builtins.hasAttr n registry.networks) myNetworks;

  # Build interface config for each network
  mkInterface = netName:
    let
      netDef = registry.networks.${netName};
      myNet = myEntry.wg.${netName};
      isP2P = (netDef.type or "hub") == "p2p";
      ifName = "wg-${netName}";
    in
      if isGateway && !isP2P then mkGatewayIface netName netDef myNet ifName
      else if isP2P then mkP2PIface netName netDef myNet ifName
      else mkClientIface netName netDef myNet ifName;

  # Gateway: listen on port, auto-discover all peers on this network
  mkGatewayIface = netName: netDef: myNet: ifName:
    let
      peerNames = builtins.filter (name:
        name != machineName
        && builtins.hasAttr netName ((registry.machines.${name}).wg or {})
      ) (builtins.attrNames registry.machines);

      peers = map (name:
        let peerNet = registry.machines.${name}.wg.${netName};
        in {
          publicKey = peerNet.publicKey;
          allowedIPs = [ "${peerNet.ip}/32" ];
          persistentKeepalive = 25;
        }
      ) peerNames;
    in {
      inherit ifName peers;
      address = "${myNet.ip}/${subnetMask netDef.subnet}";
      listenPort = netDef.port;
      secretName = myNet.secretName;
    };

  # P2P: direct link between peers, no gateway
  mkP2PIface = netName: netDef: myNet: ifName:
    let
      peerNames = builtins.filter (name:
        name != machineName
        && builtins.hasAttr netName ((registry.machines.${name}).wg or {})
      ) (builtins.attrNames registry.machines);

      peers = map (name:
        let
          peerNet = registry.machines.${name}.wg.${netName};
          # If the peer has an endpoint, use it (they're the listener)
          peerHasEndpoint = peerNet ? endpoint;
        in {
          publicKey = peerNet.publicKey;
          allowedIPs = [ "${peerNet.ip}/32" ];
          persistentKeepalive = 25;
        } // lib.optionalAttrs peerHasEndpoint {
          endpoint = peerNet.endpoint;
        }
      ) peerNames;
    in {
      inherit ifName peers;
      address = "${myNet.ip}/${subnetMask netDef.subnet}";
      listenPort = myNet.listenPort or null;
      secretName = myNet.secretName;
    };

  # Client: connect to gateway
  mkClientIface = netName: netDef: myNet: ifName:
    let
      gwNet = gwEntry.wg.${netName};
      allowedIPs =
        if netDef.fullTunnel or false then
          [ "0.0.0.0/0" "::/0" ]
        else
          [ netDef.subnet ] ++ (netDef.extraAllowedIPs or []);
    in {
      inherit ifName;
      address = "${myNet.ip}/${subnetMask netDef.subnet}";
      listenPort = null;
      secretName = myNet.secretName;
      peers = [
        {
          publicKey = gwNet.publicKey;
          endpoint = "${gwEndpoint}:${toString netDef.port}";
          inherit allowedIPs;
          persistentKeepalive = 25;
        }
      ];
    };

  interfaces = map mkInterface activeNetworks;

  # Build sops secrets for all interfaces
  secretAttrs = lib.listToAttrs (
    map (iface:
      lib.nameValuePair "wireguard/${iface.secretName}" (mkSecret iface.secretName)
    ) interfaces
  );

  # Build wg-quick interface attrset
  wgQuickInterfaces = lib.listToAttrs (
    map (iface:
      lib.nameValuePair iface.ifName {
        address = [ iface.address ];
        listenPort = iface.listenPort;
        privateKeyFile = config.sops.secrets."wireguard/${iface.secretName}".path;
        peers = iface.peers;
      }
    ) interfaces
  );

  # Gateway listen ports for firewall
  gatewayPorts = lib.concatMap (iface:
    lib.optional (iface.listenPort != null) iface.listenPort
  ) interfaces;

in {
  sops.secrets = secretAttrs;

  networking.firewall.allowedUDPPorts = lib.mkIf isGateway gatewayPorts;

  networking.wg-quick.interfaces = wgQuickInterfaces;
}
