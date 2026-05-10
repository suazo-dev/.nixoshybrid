{
  modules = [
    "user"
    "nix"
    "git"
  ];

  linuxModules = [
    "locale"
    "bootloader"
    "sops"
  ];

  darwinModules = [
    "darwin/homebrew"
    "darwin/system"
  ];
}
