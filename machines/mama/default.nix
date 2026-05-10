{
  roles = [ "storage" ];
  user = "suazo";
  stateVersion = "25.11";
  homeStateVersion = "25.11";
  hardware = "hardware-configuration.nix";

  features = [
    "core/core"
    "storage/storage"
    "terminal/terminal"
    "gui/gui"
    "dev/dev"
    "cyber/cyber"
    "net/net"
  ];

  extraModules = [ ];

  allowedUnfree = [ "claude-code" ];

  mutableUsers = true;
}
