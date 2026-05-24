{
  hostName = "papa";
  nodeName = "core";
  instanceName = "alpha";
  system = "aarch64-darwin";
  user = "suazo";
  stateVersion = "6";
  homeStateVersion = "25.11";
  hardware = "hardware-configuration.nix";

  wgPublicKeys = {
    core = "yYfVjV0C2T9kIkax2pKjU1YdEpHEDKpfmH+aKtKqjRc=";
    storage = "tc096iNfSkkOSwkSNgpJve50Zn91o5cb/K4hsGmxB0s=";
  };

  sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKwZUBkhznVjOcbgGAfQUKYOQJtNjxnTT3LDM2KMgcMB";

  extraModules = [ ];
  allowedUnfree = [ ];
  mutableUsers = true;
}
