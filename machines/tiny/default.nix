{
  hostName = "tiny";
  nodeName = "gateway";
  instanceName = "alpha";
  user = "suazo";
  system = "x86_64-linux";
  stateVersion = "25.11";
  homeStateVersion = "25.11";
  hardware = "hardware-configuration.nix";

  lan = {
    interface = "eno1";
    ip = "192.168.8.108";
    wakeMac = "00:23:24:73:05:91";
  };

  wgPublicKeys = {
    core = "wkQE+ob7KUFxcX44JEY1Lt/Ih3ujp1qZeQ3B1h5vKFA=";
    portal = "RyloTPHjCXGLn36WPczGPqnHJsjZrCjlog16AJyerGI=";
  };

  sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7RdfzUhnGivqsg+jlhyFb0V1yZY8YqZFmwpatZoDap";

  extraModules = [ ];
  allowedUnfree = [ ];
  mutableUsers = true;
}
