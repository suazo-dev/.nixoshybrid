{ spec, ... }:
let
  syncFolder = if spec.facts.sync.folder or null != null then spec.facts.sync.folder else "/home/${spec.user}/Sync";
in
{
  services.syncthing = {
    enable = true;
    user = spec.user;
    dataDir = syncFolder;
    configDir = "/home/${spec.user}/.config/syncthing";
    openDefaultPorts = true;
  };
}
