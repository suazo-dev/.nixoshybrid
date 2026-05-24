# Darwin firewall — registry-driven, zero-trust inbound.
# Internet responses flow via state tracking (pass out keep state).
# Only user's laptops (portal machines) can initiate SSH/VNC into papa.
# Tiny (gateway) cannot initiate connections into papa.
{ lib, machineName, spec, ... }:
let
  registry = import ../../network/registry.nix;
  allMachines = registry.machines;
  isCore = builtins.elem "core" (spec.roles or [ ]);

  # Only portal machines (user's laptops) can initiate connections inbound
  portalPeerIps = lib.concatMap (name:
    let machine = allMachines.${name};
    in if machine.nodeName == "portal"
       && builtins.hasAttr "portal" (machine.wg or {})
    then [ machine.wg.portal.ip ]
    else []
  ) (builtins.attrNames allMachines);

  # WireGuard ports for all networks this machine participates in
  myEntry = allMachines.${machineName} or {};
  myNetworks = builtins.attrNames (myEntry.wg or {});
  p2pPeerIps = lib.concatMap (netName:
    let
      netDef = registry.networks.${netName} or {};
      isP2P = (netDef.type or "hub") == "p2p";
    in
      if !isP2P then []
      else lib.concatMap (name:
        if name == machineName then []
        else
          let peerNet = (allMachines.${name}).wg.${netName} or {};
          in if peerNet ? ip then [ peerNet.ip ] else []
      ) (builtins.filter (name:
        builtins.hasAttr netName ((allMachines.${name}).wg or {})
      ) (builtins.attrNames allMachines))
  ) myNetworks;

  trustedIps = lib.unique (portalPeerIps ++ p2pPeerIps);
  trustedSet = lib.concatStringsSep ", " trustedIps;

  activeNetworks = builtins.filter (n: builtins.hasAttr n registry.networks) myNetworks;
  wgPorts = lib.unique (map (n: registry.networks.${n}.port) activeNetworks);
  wgPortSet = lib.concatStringsSep ", " (map toString wgPorts);

  managedAnchor = ''
    table <nixoshybrid_trusted> const { ${trustedSet} }

    # Allow all outbound — state tracking lets responses back in automatically
    pass out all keep state

    # Allow loopback
    pass in quick on lo0 all keep state

    # Allow WireGuard UDP so tunnels can re-establish (keepalives, rekeying, sleep/wake)
    pass in quick proto udp to any port { ${wgPortSet} } keep state

    # Allow SSH and VNC only from trusted machines (laptops + storage peer)
    pass in quick proto tcp from <nixoshybrid_trusted> to any port { 22, 5900 } keep state

    # Block everything else inbound
    block in all
  '';
in {
  networking.applicationFirewall = {
    enable = isCore;
    enableStealthMode = isCore;
    allowSigned = true;
    allowSignedApp = false;
    blockAllIncoming = false;
  };

  environment.etc."pf.anchors/nixoshybrid".text = lib.mkIf isCore managedAnchor;

  system.activationScripts.postActivation.text = lib.mkAfter ''
    set -eu

    pf_conf=/etc/pf.conf
    anchor_line='anchor "nixoshybrid"'
    load_line='load anchor "nixoshybrid" from "/etc/pf.anchors/nixoshybrid"'

    if ${if isCore then "true" else "false"}; then
      if [ -f "$pf_conf" ]; then
        if ! /usr/bin/grep -qF "$anchor_line" "$pf_conf"; then
          printf '\n%s\n%s\n' "$anchor_line" "$load_line" >> "$pf_conf"
        elif ! /usr/bin/grep -qF "$load_line" "$pf_conf"; then
          printf '%s\n' "$load_line" >> "$pf_conf"
        fi
        /sbin/pfctl -f "$pf_conf"
        /sbin/pfctl -e >/dev/null 2>&1 || true
      fi
    elif [ -f "$pf_conf" ]; then
      tmp_file=$(mktemp)
      { /usr/bin/grep -vF "$anchor_line" "$pf_conf" || true; } | { /usr/bin/grep -vF "$load_line" || true; } > "$tmp_file"
      /bin/cat "$tmp_file" > "$pf_conf"
      /bin/rm -f "$tmp_file"
      /sbin/pfctl -f "$pf_conf" >/dev/null 2>&1 || true
    fi
  '';
}
