{
  hostName = "tee";
  nodeName = "portal";
  instanceName = "bravo";
  user = "suazo";
  system = "x86_64-linux";
  stateVersion = "25.11";
  homeStateVersion = "25.11";
  hardware = "hardware-configuration.nix";

  wgPublicKeys = {
    portal = "ZYVWprVyyBZ3twqlG0Oy4M4yFOd1k+rg2JvDZZgS6Bc=";
  };

  sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIkwZUBkhznVjOcbgGAfQUKYOQJtNjxnTT3LDM2KMgcMB";

  extraModules = [ ];
  allowedUnfree = [ ];
  mutableUsers = true;
}
