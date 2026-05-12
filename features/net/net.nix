{
  modules = [ "openssh" ];

  linuxModules = [
    "syncthing"
    "wireguard"
  ];

  darwinModules = [
    "darwin/wireguard-app"
    "darwin/storage-mount"
    "darwin/screen-sharing"
  ];
}
