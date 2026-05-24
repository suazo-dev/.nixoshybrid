# NFS server module — registry-driven.
# Allows access from trusted core peers and any dedicated p2p storage peers.
{ lib, machineName, spec, ... }:
let
  registry = import ../../network/registry.nix;
  nfsCfg = spec.facts.storage.nfs or {};
  enabled = nfsCfg.enable or false;
  exportPath =
    if nfsCfg.exportPath or null != null then
      nfsCfg.exportPath
    else if spec.facts.sync.folder or null != null then
      spec.facts.sync.folder
    else
      "/home/${spec.user}/Sync";
  myEntry = registry.machines.${machineName};
  allMachines = registry.machines;

  # Core machines can mount storage over the routed core network.
  corePeerWgIps = lib.concatMap (name:
    let machine = allMachines.${name};
    in if name != machineName
       && machine.nodeName != "gateway"
       && builtins.hasAttr "core" (machine.wg or {})
    then [ machine.wg.core.ip ]
    else []
  ) (builtins.attrNames allMachines);

  # Dedicated p2p storage peers are still allowed when present.
  myP2PNetworks = builtins.filter (netName:
    builtins.hasAttr netName registry.networks
    && (registry.networks.${netName}.type or "hub") == "p2p"
  ) (builtins.attrNames (myEntry.wg or {}));

  p2pPeerWgIps = lib.concatMap (netName:
    lib.concatMap (name:
      if name == machineName then []
      else
        let peerNet = allMachines.${name}.wg.${netName} or {};
        in if peerNet ? ip then [ peerNet.ip ] else []
    ) (builtins.filter (name:
      builtins.hasAttr netName ((allMachines.${name}).wg or {})
    ) (builtins.attrNames allMachines))
  ) myP2PNetworks;

  peerWgIps = lib.unique (corePeerWgIps ++ p2pPeerWgIps);
  exportClients = map (ip: "${ip}(rw,sync,no_subtree_check,root_squash)") peerWgIps;
in {
  assertions = lib.optional enabled {
    assertion = exportClients != [];
    message = "NFS enabled on machine '${machineName}' but no reachable core or p2p WG peers found in registry.";
  };

  services.nfs.server = lib.mkIf enabled {
    enable = true;
    exports = ''
      ${exportPath} ${lib.concatStringsSep " " exportClients}
    '';
  };
}
