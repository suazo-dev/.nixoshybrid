{
  formFactor = "gateway";
  gui = false;
  headless = true;

  dotfiles.mode = "store-backed";

  network = {
    ethernet = true;
    wifi = false;
    useNetworkManager = false;
    useIwd = false;
  };
}
