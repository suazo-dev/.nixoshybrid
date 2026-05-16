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
      storage = { octet = 2; listen = true; };
    };
  };

  facts = {
    storage.nfs.enable = true;
    network = {
      useNetworkManager = false;
      useIwd = false;
    };
  };
}
