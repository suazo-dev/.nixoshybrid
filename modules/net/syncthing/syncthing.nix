{ spec, ... }:
let
  syncFolder = spec.facts.sync.folder or "/home/${spec.user}/Sync";
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
