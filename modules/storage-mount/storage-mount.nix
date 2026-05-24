# Storage mount module — discovers a reachable storage target from the registry.
# No machine names hardcoded. Uses the normal WG reachability rules to find
# the storage peer and mount over the best available path.
{ pkgs, lib, machineName, spec, ... }:
let
  registry = import ../../network/registry.nix;
  hosts = import ../../network/hosts.nix { inherit lib; };
  mountCfg = spec.facts.storage.nfs or {};

  # Find reachable storage peers using the registry's normal WG reachability rules.
  storagePeers = builtins.filter (name:
    name != machineName
    && builtins.elem "storage" (registry.machines.${name}.roles or [ ])
    && hosts.resolveIp machineName name != null
  ) (builtins.attrNames registry.machines);

  # Use the first reachable storage peer as the remote host.
  storageTarget = if storagePeers != [] then builtins.head storagePeers else null;

  remoteHost = if storageTarget != null then hosts.resolveIp machineName storageTarget else "";
  remotePath =
    if mountCfg.remotePath or null != null then
      mountCfg.remotePath
    else if spec.facts.sync.folder or null != null then
      spec.facts.sync.folder
    else
      "/home/${spec.user}/Sync";
  mountPoint = if mountCfg.mountPoint or null != null then mountCfg.mountPoint else "/Volumes/storage";

  mountStorageScript = pkgs.writeShellScriptBin "mount-storage" ''
    set -euo pipefail

    remote_host=${builtins.toJSON remoteHost}
    remote_path=${builtins.toJSON remotePath}
    mount_point=${builtins.toJSON mountPoint}

    if [ -z "$remote_host" ]; then
      printf 'storage host not found — no reachable storage peer in registry.\n' >&2
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
  assertions = lib.optional (storagePeers != [ ]) {
    assertion = builtins.length storagePeers == 1;
    message = "Darwin storage mount for machine '${machineName}' expects exactly one storage peer.";
  };

  environment.systemPackages = [
    mountStorageScript
    umountStorageScript
  ];
}
