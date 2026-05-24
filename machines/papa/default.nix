{
  hostName = "papa";
  nodeName = "core";
  instanceName = "alpha";
  system = "aarch64-darwin";
  user = "suazo";
  stateVersion = "6";
  homeStateVersion = "25.11";
  hardware = "hardware-configuration.nix";

  lan = {
    interface = "en0";
    ip = "192.168.8.11";
  };

  wgPublicKeys = {
    core = "XRzfB39T5pme2JitUbiJK9j7HsCpZZagOTTKbCHvHAo=";
  };

  sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5eRdGcbhvts60t3K2ckcfLA7R/gc39YDVCUPZf9qgL";

  extraModules = [ ];
  allowedUnfree = [ ];
  mutableUsers = true;
}
