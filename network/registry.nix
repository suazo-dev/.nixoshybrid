let
  unique = list:
    builtins.foldl' (acc: item: if builtins.elem item acc then acc else acc ++ [ item ]) [ ] list;

  machineRoot = ../machines;
  nodeRoot = ../nodes;
  machineEntries = builtins.readDir machineRoot;
  machineNames = builtins.filter (name:
    machineEntries.${name} == "directory"
    && builtins.pathExists (machineRoot + "/${name}/default.nix")
  ) (builtins.attrNames machineEntries);

  importMachine = name: import (machineRoot + "/${name}/default.nix");
  importNode = name: import (nodeRoot + "/${name}.nix");

  systemClass = system:
    if builtins.match ".*-linux" system != null then "linux"
    else if builtins.match ".*-darwin" system != null then "darwin"
    else throw "Unsupported system '${system}'.";

  instanceOrdinals = {
    alpha = 0;
    bravo = 1;
    charlie = 2;
    delta = 3;
    echo = 4;
  };

  instanceOffset = instanceName:
    if builtins.hasAttr instanceName instanceOrdinals then
      instanceOrdinals.${instanceName}
    else
      throw "Unknown instanceName '${instanceName}'.";

  # Scan all machines
  rawMachines = builtins.listToAttrs (map (machineName:
    let raw = importMachine machineName;
    in {
      name = machineName;
      value = {
        hostName = raw.hostName or machineName;
        system = raw.system or "x86_64-linux";
        nodeName = raw.nodeName;
        instanceName = raw.instanceName;
        lan = raw.lan or {};
        wgPublicKeys = raw.wgPublicKeys or {};
        sshPublicKey = raw.sshPublicKey or null;
      };
    }
  ) machineNames);

  # Duplicate detection
  duplicateNodeInstances = builtins.filter (key:
    builtins.length (builtins.filter (machineName:
      let m = rawMachines.${machineName};
      in "${m.nodeName}:${m.instanceName}" == key
    ) machineNames) > 1
  ) (unique (map (machineName:
    let m = rawMachines.${machineName};
    in "${m.nodeName}:${m.instanceName}"
  ) machineNames));

  _duplicateCheck =
    if duplicateNodeInstances != [ ] then
      throw "Duplicate nodeName/instanceName: ${builtins.concatStringsSep ", " duplicateNodeInstances}"
    else
      null;

  # WireGuard network definitions
  networks = {
    core = {
      subnet = "10.0.0.0/24";
      port = 51820;
      hostPriority = 300;
      fullTunnel = true;
      extraAllowedIPs = [ ];
    };

    portal = {
      subnet = "10.1.0.0/24";
      port = 51821;
      hostPriority = 200;
      fullTunnel = false;
      extraAllowedIPs = [ "10.0.0.0/24" ];
    };

    storage = {
      subnet = "10.2.0.0/24";
      port = 51822;
      hostPriority = 100;
      type = "p2p";
      fullTunnel = false;
      extraAllowedIPs = [ ];
    };
  };

  # Infrastructure config
  endpoint = {
    domain = "teenytiny.duckdns.org";
    duckdnsDomain = "teenytiny";
  };

  lan = {
    subnet = "192.168.8.0/24";
    gatewayIp = "192.168.8.1";
    nameservers = [ "192.168.8.1" "1.1.1.1" ];
  };

  subnetPrefix = subnet:
    let match = builtins.match "([0-9]+\\.[0-9]+\\.[0-9]+)\\.[0-9]+/[0-9]+" subnet;
    in if match == null then throw "Unsupported subnet '${subnet}'." else builtins.head match;

  # Compute WireGuard address from node's base octet + instance offset
  wgAddress = nodeName: instanceName: networkName:
    let
      nodeSpec = importNode nodeName;
      nodeNet = nodeSpec.network.wg.${networkName}
        or (throw "Node '${nodeName}' does not participate in network '${networkName}'.");
      baseOctet = nodeNet.octet;
      offset = instanceOffset instanceName;
    in baseOctet + offset;

  # Build WireGuard record for a machine on a network — all data from machine file
  mkWgRecord = machineSpec: networkName:
    let
      nodeSpec = importNode machineSpec.nodeName;
      nodeNet = nodeSpec.network.wg.${networkName};
      octet = wgAddress machineSpec.nodeName machineSpec.instanceName networkName;
      ip = "${subnetPrefix networks.${networkName}.subnet}.${toString octet}";
      secretName = "${machineSpec.nodeName}-${machineSpec.instanceName}-${networkName}";
      publicKey = machineSpec.wgPublicKeys.${networkName}
        or (throw "Machine '${machineSpec.hostName}' missing wgPublicKeys.${networkName}.");
      shouldListen = nodeNet.listen or false;
      lanIp = machineSpec.lan.ip or null;
    in
      { inherit ip secretName publicKey; }
      // (if shouldListen then { listenPort = networks.${networkName}.port; } else { })
      // (if shouldListen && lanIp != null then { endpoint = "${lanIp}:${toString networks.${networkName}.port}"; } else { });

  # Build full machine records
  baseMachines = builtins.listToAttrs (map (machineName:
    let
      machineSpec = rawMachines.${machineName};
      nodeSpec = importNode machineSpec.nodeName;
      wgNetworkNames = builtins.attrNames (nodeSpec.network.wg or {});
      sysClass = systemClass machineSpec.system;
    in {
      name = machineName;
      value = machineSpec // {
        systemClass = sysClass;
        roles = [ machineSpec.nodeName ];
        secretFileName = "${machineSpec.nodeName}-${machineSpec.instanceName}";
        lan = machineSpec.lan or {};
        wg = builtins.listToAttrs (map (networkName: {
          name = networkName;
          value = mkWgRecord machineSpec networkName;
        }) wgNetworkNames);
      };
    }
  ) machineNames);

  # SSH keys derived from machines — all machines trust all others
  sshKeys = builtins.listToAttrs (builtins.filter (x: x.value != null) (map (machineName:
    let machine = baseMachines.${machineName};
    in {
      name = "${machine.nodeName}-${machine.instanceName}";
      value = machine.sshPublicKey;
    }
  ) machineNames));

  sshAuthorizedKeysFor = machineName:
    let
      machine = baseMachines.${machineName};
      otherNames = builtins.filter (name: name != machineName) machineNames;
    in unique (map (name:
      "${baseMachines.${name}.nodeName}-${baseMachines.${name}.instanceName}"
    ) (builtins.filter (name: baseMachines.${name}.sshPublicKey != null) otherNames));

  machines = builtins.listToAttrs (map (machineName: {
    name = machineName;
    value = baseMachines.${machineName} // {
      sshAuthorizedKeys = sshAuthorizedKeysFor machineName;
    };
  }) machineNames);

  # Find gateway dynamically
  gatewayMachineNames = builtins.filter (machineName:
    machines.${machineName}.nodeName == "gateway"
  ) machineNames;

  _gatewayCheck =
    if builtins.length gatewayMachineNames != 1 then
      throw "Expected exactly one gateway machine, found ${toString (builtins.length gatewayMachineNames)}."
    else
      null;

  gatewayMachineName = builtins.head gatewayMachineNames;
  gatewayMachine = machines.${gatewayMachineName};
in {
  inherit machineNames machines networks sshKeys instanceOrdinals lan endpoint;

  machineFor = machineName: machines.${machineName};

  instanceKey = machineName:
    let machine = machines.${machineName};
    in "${machine.nodeName}:${machine.instanceName}";

  gateway = {
    endpoint = endpoint.domain;
    duckdnsDomain = endpoint.duckdnsDomain;
    machineName = gatewayMachineName;
    nodeName = gatewayMachine.nodeName;
    instanceName = gatewayMachine.instanceName;
    hostName = gatewayMachine.hostName;
  };
}
