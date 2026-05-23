{
  formFactor = "generic";
  gui = true;
  headless = false;

  theme = {
    dark = true;
    cursor = {
      package = "bibata-cursors";
      name = "Bibata-Modern-Classic";
      size = 24;
    };
  };

  dotfiles.mode = "store-backed";

  network = {
    ethernet = false;
    wifi = false;
    useNetworkManager = false;
    useIwd = false;
  };

  sync.folder = null;

  hermes = {
    gateway = false;
  };

  storage = {
    nfs = {
      enable = false;
      exportPath = null;
      mountPoint = null;
      remotePath = null;
    };
  };
}
