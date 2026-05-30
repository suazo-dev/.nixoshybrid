{
  supportedSystems = [ "linux" ];

  modules = [
    "duckdns"
  ];

  linuxModules = [ ];

  network = {
    wg = {
      core = { octet = 1; listen = true; };
      portal = { octet = 1; };
    };
  };

  facts = {
    gui = false;
    headless = true;
    network = {
      useNetworkManager = false;
      useIwd = false;
    };
    sync.folder = null;
  };
}
