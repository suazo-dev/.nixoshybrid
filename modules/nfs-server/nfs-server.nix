# NFS server module — registry-driven.
# Allows access from peers on shared p2p WG networks.
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

  # Find peers on shared p2p WG networks — those get NFS access
  myP2PNetworks = builtins.filter (netName:
    builtins.hasAttr netName registry.networks
    && (registry.networks.${netName}.type or "hub") == "p2p"
  ) (builtins.attrNames (myEntry.wg or {}));

  peerWgIps = lib.concatMap (netName:
    lib.concatMap (name:
      if name == machineName then []
      else
        let peerNet = (registry.machines.${name}).wg.${netName} or {};
        in if peerNet ? ip then [ peerNet.ip ] else []
    ) (builtins.filter (name:
      builtins.hasAttr netName ((registry.machines.${name}).wg or {})
    ) (builtins.attrNames registry.machines))
  ) myP2PNetworks;

  exportClients = map (ip: "${ip}(rw,sync,no_subtree_check,no_root_squash)") peerWgIps;
in {
  assertions = lib.optional enabled {
    assertion = exportClients != [];
    message = "NFS enabled on machine '${machineName}' but no p2p WG peers found in registry.";
  };

  services.nfs.server = lib.mkIf enabled {
    enable = true;
    exports = ''
      ${exportPath} ${lib.concatStringsSep " " exportClients}
    '';
  };
}
