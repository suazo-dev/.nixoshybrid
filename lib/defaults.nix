{
  system = "x86_64-linux";
  user = "suazo";

  extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  allowedUnfree = [ ];
  mutableUsers = true;
  repoDirName = ".nixoshybrid";
}
