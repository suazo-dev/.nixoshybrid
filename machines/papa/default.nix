{
  system = "aarch64-darwin";
  roles = [ "core" ];
  user = "suazo";
  stateVersion = "6";
  homeStateVersion = "25.11";
  hardware = "hardware-configuration.nix";

  features = [
    "core/core"
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
