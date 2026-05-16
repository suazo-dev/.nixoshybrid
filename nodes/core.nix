{
  supportedSystems = [ "linux" "darwin" ];

  remove = [
    "duckdns"
    "nfs-server"
  ];

  removeLinux = [ ];

  network = {
    wg = {
      core = { octet = 3; };
      storage = { octet = 1; };
    };
  };

  facts = {
    storage.nfs = {
      mountPoint = "/Volumes/storage";
      remotePath = "/home/suazo/Sync";
    };
  };
}
