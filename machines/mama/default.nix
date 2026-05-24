{
  hostName = "mama";
  nodeName = "storage";
  instanceName = "alpha";
  user = "suazo";
  system = "x86_64-linux";
  stateVersion = "25.11";
  homeStateVersion = "25.11";
  hardware = "hardware-configuration.nix";

  lan = {
    interface = "eno1";
    ip = "192.168.8.10";
    wakeMac = "c4:65:16:b6:8c:3c";
  };

  wgPublicKeys = {
    core = "9nbLPKBbdKz7AHIAPsO3zI5L4xcPNfWtNRrIxWn7AV4=";
  };

  sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKwZUBkhznVjOcbgGAfQUKYOQJtNjxnTT3LDM2KMgcMB";

  extraModules = [ ];
  allowedUnfree = [ ];
  mutableUsers = true;
}
