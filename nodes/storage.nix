{
  supportedSystems = [ "linux" ];

  remove = [
    "duckdns"
  ];

  removeLinux = [
    "networkmanager"
    "iwd"
  ];

  network = {
    wg = {
      core = { octet = 2; };
    };
  };

  facts = {
    hermes.gateway = true;
    storage.nfs.enable = true;
    network = {
      useNetworkManager = false;
      useIwd = false;
    };
  };
}
