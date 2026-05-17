# Darwin firewall — lock down like nftables does for linux.
# Block ALL incoming except from WireGuard peer IPs.
{ lib, machineName, spec, ... }:
let
  registry = import ../../network/registry.nix;
  allMachines = registry.machines;
  isCore = builtins.elem "core" (spec.roles or [ ]);

  # Collect all WG IPs from all machines on all non-p2p networks
  adminNetworks = builtins.filter (netName:
    (registry.networks.${netName}.type or "hub") != "p2p"
  ) (builtins.attrNames registry.networks);

  allWgIps = lib.unique (lib.concatMap (otherMachineName:
    lib.concatMap (netName:
      let net = (allMachines.${otherMachineName}.wg or {}).${netName} or null;
      in lib.optional (net != null && net ? ip) net.ip
    ) adminNetworks
  ) (builtins.attrNames allMachines));

  # Also include p2p peer IPs for this machine
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

  allowedSources = lib.unique (builtins.filter (ip: ip != null) (allWgIps ++ p2pPeerIps));
  sourceSet = lib.concatStringsSep ", " allowedSources;

  managedAnchor = ''
    table <nixoshybrid_wg_sources> const { ${sourceSet} }

    # Allow all outbound, track state so replies come back in
    pass out all keep state

    # Allow all traffic from WireGuard peers
    pass in quick from <nixoshybrid_wg_sources> keep state

    # Allow loopback
    pass in quick on lo0 all keep state

    # Block everything else inbound
    block in all
  '';
in {
  networking.applicationFirewall = {
    enable = isCore;
    enableStealthMode = isCore;
    allowSigned = true;
    allowSignedApp = false;
    blockAllIncoming = true;
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
