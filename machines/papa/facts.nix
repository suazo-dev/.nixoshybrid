{
  formFactor = "mac-mini";
  gui = true;
  headless = false;

  dotfiles.mode = "store-backed";

  network = {
    ethernet = true;
    wifi = false;
  };

  sync.folder = "/Users/suazo/Sync";

  storage.nfs = {
    mountPoint = "/Volumes/storage";
    remotePath = "/home/suazo/Sync";
  };
}
