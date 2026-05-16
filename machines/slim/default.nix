{
  hostName = "slim";
  nodeName = "portal";
  instanceName = "alpha";
  user = "suazo";
  system = "x86_64-linux";
  stateVersion = "25.11";
  homeStateVersion = "25.11";
  hardware = "hardware-configuration.nix";

  wgPublicKeys = {
    portal = "IkovrxdCMGX0j5LmowsZYOE6Nxdm2kvRMBWWrpbu6FY=";
  };

  sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZmKT4DsStSgGCTBBHFk4B4YJ+NW2zXAZisaKF3MEpo";

  extraModules = [ ];
  allowedUnfree = [ ];
  mutableUsers = true;
}
