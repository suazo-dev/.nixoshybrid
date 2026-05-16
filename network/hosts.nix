{ lib }:
let
  registry = import ./registry.nix;
  allMachines = registry.machines;

  sortNetworks = networks:
    builtins.sort (a: b: (registry.networks.${a}.hostPriority or 0) > (registry.networks.${b}.hostPriority or 0)) networks;

  resolveIp = fromMachineName: toMachineName:
    if !(builtins.hasAttr fromMachineName allMachines) || !(builtins.hasAttr toMachineName allMachines) then
      null
    else
      let
        from = allMachines.${fromMachineName};
        to = allMachines.${toMachineName};
        fromNetworks = builtins.attrNames (from.wg or { });
        toNetworks = builtins.attrNames (to.wg or { });
        sharedNetworks = builtins.filter (n: builtins.elem n toNetworks) fromNetworks;
        gatewayReach = if from.nodeName == "gateway" then toNetworks else [ ];
        routedNetworks = lib.concatMap (fromNet:
          let extraIPs = registry.networks.${fromNet}.extraAllowedIPs or [ ];
          in builtins.filter (toNet: builtins.elem registry.networks.${toNet}.subnet extraIPs) toNetworks
        ) fromNetworks;
        reachableNetworks = sortNetworks (builtins.foldl' (acc: item: if builtins.elem item acc then acc else acc ++ [ item ]) [ ] (sharedNetworks ++ gatewayReach ++ routedNetworks));
        allReachable = if to.nodeName == "gateway" then sortNetworks fromNetworks else reachableNetworks;
      in
        if allReachable != [ ] then
          to.wg.${builtins.head allReachable}.ip
        else
          to.lan.ip or null;

  hostsFor = machineName:
    let
      otherMachineNames = builtins.filter (name: name != machineName) (builtins.attrNames allMachines);
    in
      lib.filterAttrs (_: value: value != null) (
        builtins.listToAttrs (map (otherName:
          let machine = allMachines.${otherName};
          in {
            name = machine.hostName;
            value = resolveIp machineName otherName;
          }
        ) otherMachineNames)
      );

  hostsFileFor = machineName:
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: ip: "${ip} ${name}") (hostsFor machineName));
in {
  inherit resolveIp hostsFor hostsFileFor;

  mkHostsModule = machineName: {
    networking.extraHosts = lib.mkIf (builtins.hasAttr machineName allMachines) (hostsFileFor machineName);
  };
}
