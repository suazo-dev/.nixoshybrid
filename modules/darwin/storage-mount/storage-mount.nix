# Storage mount module — discovers storage target from registry by role.
# No machine names hardcoded. Finds peers on shared p2p WG networks
# that have the "storage" role.
{ pkgs, lib, machineName, spec, ... }:
let
  registry = import ../../../network/registry.nix;
  mountCfg = spec.facts.storage.nfs or {};
  myEntry = registry.machines.${machineName};

  # Find storage peers: machines on a shared p2p WG network
  myP2PNetworks = builtins.filter (netName:
    builtins.hasAttr netName registry.networks
    && (registry.networks.${netName}.type or "hub") == "p2p"
  ) (builtins.attrNames (myEntry.wg or {}));

  storagePeers = lib.concatMap (netName:
    builtins.filter (name:
      name != machineName
      && builtins.hasAttr netName ((registry.machines.${name}).wg or {})
    ) (builtins.attrNames registry.machines)
  ) myP2PNetworks;

  # Use the first storage peer's WG IP as the remote host
  storageTarget = if storagePeers != [] then builtins.head storagePeers else null;
  storageTargetNet = if storageTarget != null then
    let
      sharedNet = builtins.head (builtins.filter (netName:
        builtins.hasAttr netName ((registry.machines.${storageTarget}).wg or {})
      ) myP2PNetworks);
    in registry.machines.${storageTarget}.wg.${sharedNet}
  else null;

  remoteHost = if storageTargetNet != null then storageTargetNet.ip else "";
  remotePath = mountCfg.remotePath or spec.facts.sync.folder or "/home/${spec.user}/Sync";
  mountPoint = mountCfg.mountPoint or "/Volumes/storage";

  mountStorageScript = pkgs.writeShellScriptBin "mount-storage" ''
    set -euo pipefail

    remote_host=${builtins.toJSON remoteHost}
    remote_path=${builtins.toJSON remotePath}
    mount_point=${builtins.toJSON mountPoint}

    if [ -z "$remote_host" ]; then
      printf 'storage host not found — no p2p peer in registry.\n' >&2
      exit 1
    fi

    sudo mkdir -p "$mount_point"

    if /sbin/mount | /usr/bin/grep -q "on $mount_point "; then
      printf 'storage is already mounted at %s\n' "$mount_point"
      exit 0
    fi

    sudo /sbin/mount -t nfs -o vers=4,resvport,tcp "$remote_host:$remote_path" "$mount_point"
  '';

  umountStorageScript = pkgs.writeShellScriptBin "umount-storage" ''
    set -euo pipefail

    mount_point=${builtins.toJSON mountPoint}

    if ! /sbin/mount | /usr/bin/grep -q "on $mount_point "; then
      printf 'storage is not mounted at %s\n' "$mount_point"
      exit 0
    fi

    sudo /sbin/umount "$mount_point"
  '';
in {
  environment.systemPackages = [
    mountStorageScript
    umountStorageScript
  ];
}
