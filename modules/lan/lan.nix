{ lib, machineName, spec, ... }:
let
  registry = import ../../network/registry.nix;
  machineEntry = registry.machines.${machineName} or { };
  lanCfg = machineEntry.lan or { };
  hasStaticLan = lanCfg ? ip;
  lanInterface = lanCfg.interface or null;
  isLinux = lib.hasSuffix "-linux" spec.system;
in lib.mkIf (isLinux && hasStaticLan) ({
  assertions = [
    {
      assertion = lanInterface != null;
      message = "Machine '${machineName}' needs 'lan.interface' metadata before it can carry node '${spec.nodeName}' instance '${spec.instanceName}' with static LAN address ${lanCfg.ip}.";
    }
  ];

  # Static LAN hosts should not rely on DHCP for routes or DNS.
  networking.useDHCP = lib.mkForce false;
  networking.defaultGateway = {
    address = registry.lan.gatewayIp;
    interface = lanInterface;
  };
  networking.nameservers = registry.lan.nameservers;
} // lib.optionalAttrs (lanInterface != null) {
  networking.interfaces.${lanInterface} = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = lanCfg.ip;
        prefixLength = 24;
      }
    ];
  };
})
