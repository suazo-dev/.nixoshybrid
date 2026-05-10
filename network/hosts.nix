{ lib }:
let
  registry = import ./registry.nix;
  allMachines = registry.machines;

  resolveIp = fromName: toName:
    if !(builtins.hasAttr fromName allMachines) || !(builtins.hasAttr toName allMachines) then
      null
    else
      let
        from = allMachines.${fromName};
        to = allMachines.${toName};
        fromNetworks = builtins.attrNames (from.wg or { });
        toNetworks = builtins.attrNames (to.wg or { });
        sharedNetworks = builtins.filter (n: builtins.elem n toNetworks) fromNetworks;
        isGateway = fromName == registry.gateway.machineName;
        gatewayReach = if isGateway then toNetworks else [ ];
        reachableNetworks = lib.unique (sharedNetworks ++ gatewayReach);
        toIsGateway = toName == registry.gateway.machineName;
        allReachable = if toIsGateway then fromNetworks else reachableNetworks;
      in
        if allReachable != [ ] then
          (to.wg.${builtins.head allReachable}).ip
        else
          to.lan.ip or null;

  hostsFor = machineName:
    let
      otherNames = builtins.filter (name: name != machineName) (builtins.attrNames allMachines);
    in
      lib.filterAttrs (_: value: value != null) (lib.genAttrs otherNames (name: resolveIp machineName name));

  hostsFileFor = machineName:
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: ip: "${ip} ${name}") (hostsFor machineName));
in {
  inherit resolveIp hostsFor hostsFileFor;

  mkHostsModule = machineName: {
    networking.extraHosts = lib.mkIf (builtins.hasAttr machineName allMachines) (hostsFileFor machineName);
  };
}
