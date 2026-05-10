{
  roles = [
    "gateway"
    "service"
    "edge"
  ];
  user = "suazo";
  stateVersion = "25.11";
  homeStateVersion = "25.11";
  hardware = "hardware-configuration.nix";

  features = [
    "core/core"
    "terminal/terminal"
    "cyber/cyber"
    "net/net"
  ];

  extraModules = [
    "duckdns"
  ];

  mutableUsers = true;
}
