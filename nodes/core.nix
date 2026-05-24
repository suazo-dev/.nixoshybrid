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
    };
  };

  facts = {
    storage.nfs = {
      mountPoint = "/Volumes/storage";
      remotePath = "/home/suazo/Sync";
    };
  };
}
