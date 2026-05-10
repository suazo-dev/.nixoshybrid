{
  system = "x86_64-linux";
  user = "suazo";

  extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  features = [ "core/core" "cyber/cyber" ];
  allowedUnfree = [ ];
  roles = [ ];
  mutableUsers = true;
  repoDirName = ".nixoshybrid";
}
