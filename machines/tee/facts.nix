{
  formFactor = "portal";
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
    ethernet = true;
    wifi = true;
    useNetworkManager = true;
    useIwd = true;
  };

  sync.folder = "/home/suazo/Sync";
}
