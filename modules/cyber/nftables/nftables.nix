# Firewall module — fully registry-driven.
# Interface names and IPs derived from network/registry.nix.
{ lib, machineName, spec, ... }:
let
  registry = import ../../../network/registry.nix;
  hasRole = role: builtins.elem role spec.roles;
  isGateway = machineName == registry.gateway.machineName;
  storageCfg = spec.facts.storage or {};
  nfsEnabled = storageCfg.nfs.enable or false;

  # Derive WG interface names from registry for this machine
  myEntry = registry.machines.${machineName} or {};
  myNetworks = builtins.attrNames (myEntry.wg or {});
  activeNetworks = builtins.filter (n: builtins.hasAttr n registry.networks) myNetworks;

  # All WG interface names for this machine
  myWgInterfaces = map (n: "wg-${n}") activeNetworks;
  myWgInterfaceSet = lib.concatStringsSep ", " (map (n: "\"${n}\"") myWgInterfaces);

  # Gateway-specific: separate hub networks from p2p
  hubNetworks = builtins.filter (n:
    (registry.networks.${n}.type or "hub") != "p2p"
  ) activeNetworks;
  hubInterfaces = map (n: "wg-${n}") hubNetworks;
  hubInterfaceSet = lib.concatStringsSep ", " (map (n: "\"${n}\"") hubInterfaces);

  # Full-tunnel networks get masquerade
  fullTunnelNetworks = builtins.filter (n:
    registry.networks.${n}.fullTunnel or false
  ) hubNetworks;
  fullTunnelInterfaces = map (n: "wg-${n}") fullTunnelNetworks;

  # Gateway listen ports from registry
  wgPorts = lib.concatStringsSep ", " (
    map (n: toString registry.networks.${n}.port) hubNetworks
  );

  # For storage/core: find peers on shared p2p networks for NFS access
  p2pPeerWgIps = lib.concatMap (netName:
    let
      netDef = registry.networks.${netName} or {};
      isP2P = (netDef.type or "hub") == "p2p";
    in
      if !isP2P then []
      else lib.concatMap (name:
        if name == machineName then []
        else
          let peerNet = (registry.machines.${name}).wg.${netName} or {};
          in if peerNet ? ip then [ peerNet.ip ] else []
      ) (builtins.filter (name:
        builtins.hasAttr netName ((registry.machines.${name}).wg or {})
      ) (builtins.attrNames registry.machines))
  ) activeNetworks;

in {
  boot.kernel.sysctl = lib.mkIf (hasRole "gateway") {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall.enable = hasRole "portal";
  networking.nftables.enable = hasRole "gateway" || hasRole "core" || hasRole "storage";

  networking.nftables.tables = lib.mkMerge [

    (lib.mkIf (hasRole "gateway") {
      gateway = {
        family = "inet";
        content = ''
          chain input {
            type filter hook input priority 0; policy drop;
            iifname "lo" accept
            ct state established,related accept
            iifname { ${hubInterfaceSet} } accept
            ip protocol icmp accept
            udp dport { ${wgPorts} } accept
            tcp dport 22 accept
          }

          chain forward {
            type filter hook forward priority 0; policy drop;
            ct state established,related accept
            iifname { ${hubInterfaceSet} } oifname { ${hubInterfaceSet} } accept
            ${lib.concatStringsSep "\n            " (map (iface:
              "iifname \"${iface}\" oifname != { ${hubInterfaceSet} } accept"
            ) fullTunnelInterfaces)}
          }

          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;
            ${lib.concatStringsSep "\n            " (map (iface:
              "iifname \"${iface}\" oifname != { ${hubInterfaceSet} } masquerade"
            ) fullTunnelInterfaces)}
          }
        '';
      };
    })

    (lib.mkIf (hasRole "core") {
      core = {
        family = "inet";
        content = ''
          chain input {
            type filter hook input priority 0; policy drop;
            iifname "lo" accept
            ct state established,related accept
            ${lib.concatStringsSep "\n            " (map (iface:
              "iifname \"${iface}\" accept"
            ) myWgInterfaces)}
            ip protocol icmp accept
          }

          chain forward {
            type filter hook forward priority 0; policy drop;
          }

          chain output {
            type filter hook output priority 0; policy accept;
          }
        '';
      };
    })

    (lib.mkIf (hasRole "storage") {
      storage = {
        family = "inet";
        content = ''
          chain input {
            type filter hook input priority 0; policy drop;
            iifname "lo" accept
            ct state established,related accept
            ${lib.concatStringsSep "\n            " (map (iface:
              "iifname \"${iface}\" accept"
            ) myWgInterfaces)}
            ${lib.optionalString nfsEnabled (lib.concatStringsSep "\n            " (lib.concatMap (ip: [
              "ip saddr ${ip} tcp dport 2049 accept"
              "ip saddr ${ip} udp dport 2049 accept"
            ]) p2pPeerWgIps))}
            ip protocol icmp accept
          }

          chain forward {
            type filter hook forward priority 0; policy drop;
          }

          chain output {
            type filter hook output priority 0; policy accept;
          }
        '';
      };
    })
  ];
}
