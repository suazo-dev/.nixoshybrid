# Firewall module — fully registry-driven.
# Interface names and IPs derived from network/registry.nix.
{ lib, machineName, spec, ... }:
let
  registry = import ../../network/registry.nix;
  hasRole = role: builtins.elem role spec.roles;
  storageCfg = spec.facts.storage or {};
  nfsEnabled = storageCfg.nfs.enable or false;
  hermesEnabled = spec.facts.hermes.gateway or false;

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
  p2pNetworks = builtins.filter (n:
    (registry.networks.${n}.type or "hub") == "p2p"
  ) activeNetworks;
  hubInterfaces = map (n: "wg-${n}") hubNetworks;
  p2pInterfaces = map (n: "wg-${n}") p2pNetworks;
  hubInterfaceSet = lib.concatStringsSep ", " (map (n: "\"${n}\"") hubInterfaces);
  p2pInterfaceSet = lib.concatStringsSep ", " (map (n: "\"${n}\"") p2pInterfaces);

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

  # Trusted user machine IPs — non-gateway machines on core + portal machines.
  # These are the user's own machines (papa, mama, slim, tee).
  # Tiny (gateway) is excluded — it routes traffic but cannot initiate into protected machines.
  allMachines = registry.machines;
  trustedUserIps =
    let
      coreIps = lib.concatMap (name:
        let machine = allMachines.${name};
        in if name != machineName
           && machine.nodeName != "gateway"
           && builtins.hasAttr "core" (machine.wg or {})
        then [ machine.wg.core.ip ]
        else []
      ) (builtins.attrNames allMachines);
      portalIps = lib.concatMap (name:
        let machine = allMachines.${name};
        in if machine.nodeName == "portal"
           && builtins.hasAttr "portal" (machine.wg or {})
        then [ machine.wg.portal.ip ]
        else []
      ) (builtins.attrNames allMachines);
    in lib.unique (coreIps ++ portalIps);
  trustedUserIpSet = lib.concatStringsSep ", " trustedUserIps;

  # P2P listen ports on this machine (for WireGuard handshakes from LAN peers)
  p2pListenPorts = lib.concatMap (netName:
    let
      myNet = myEntry.wg.${netName} or {};
      netDef = registry.networks.${netName} or {};
      isP2P = (netDef.type or "hub") == "p2p";
    in if isP2P && myNet ? listenPort then [ myNet.listenPort ] else []
  ) activeNetworks;

in {
  boot.kernel.sysctl = lib.mkIf (hasRole "gateway") {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall.enable = false;
  networking.nftables.enable = true;

  networking.nftables.tables = lib.mkMerge [

    (lib.mkIf (hasRole "gateway") {
      gateway = {
        family = "inet";
        content = ''
          # Emergency LAN access — knockd adds IPs here temporarily (60s timeout)
          set emergency_ssh_sources {
            type ipv4_addr
            flags timeout
          }

          chain input {
            type filter hook input priority 0; policy drop;
            iifname "lo" accept
            ct state established,related accept
            iifname { ${hubInterfaceSet} } accept
            ip protocol icmp accept
            udp dport { ${wgPorts} } accept
            ip saddr @emergency_ssh_sources tcp dport 22 accept
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
            ${lib.concatStringsSep "\n            " (map (port:
              "udp dport ${toString port} accept"
            ) p2pListenPorts)}
            ${lib.optionalString (trustedUserIps != []) "ip saddr { ${trustedUserIpSet} } tcp dport 22 accept"}
            ${lib.optionalString nfsEnabled (lib.concatStringsSep "\n            " (lib.concatMap (ip: [
              "ip saddr ${ip} tcp dport 2049 accept"
              "ip saddr ${ip} udp dport 2049 accept"
            ]) p2pPeerWgIps))}
            ${lib.optionalString (hermesEnabled && trustedUserIps != []) "ip saddr { ${trustedUserIpSet} } tcp dport { 8642, 9119 } accept"}
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

    (lib.mkIf (hasRole "portal") {
      portal = {
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
  ];
}
