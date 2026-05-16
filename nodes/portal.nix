{
  supportedSystems = [ "linux" ];

  remove = [
    "duckdns"
    "nfs-server"
  ];

  removeLinux = [ ];

  network = {
    wg = {
      portal = { octet = 2; };
    };
  };

  facts = {
    network = {
      useNetworkManager = true;
      useIwd = true;
    };
  };
}
