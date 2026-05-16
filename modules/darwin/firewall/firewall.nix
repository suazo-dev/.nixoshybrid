{ lib, machineName, spec, ... }:
let
  registry = import ../../../network/registry.nix;
  allMachines = registry.machines;
  adminNetworks = builtins.filter (netName:
    (registry.networks.${netName}.type or "hub") != "p2p"
  ) (builtins.attrNames registry.networks);
  allWgIps = lib.unique (lib.concatMap (otherMachineName:
    lib.concatMap (netName:
      let net = (allMachines.${otherMachineName}.wg or {}).${netName} or null;
      in lib.optional (net != null && net ? ip) net.ip
    ) adminNetworks
  ) (builtins.attrNames allMachines));
  allowedSources = builtins.filter (ip: ip != null) allWgIps;
  sourceSet = lib.concatStringsSep ", " allowedSources;
  isCore = builtins.elem "core" (spec.roles or [ ]);
  screensharingEnabled = spec.facts.gui or false;
  managedAnchor = ''
    table <nixoshybrid_wg_sources> const { ${sourceSet} }

    pass in quick inet proto tcp from <nixoshybrid_wg_sources> to any port 22 keep state
    ${lib.optionalString screensharingEnabled "pass in quick inet proto tcp from <nixoshybrid_wg_sources> to any port 5900 keep state"}

    block in quick inet proto tcp to any port 22
    ${lib.optionalString screensharingEnabled "block in quick inet proto tcp to any port 5900"}
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
