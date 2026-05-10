{
  allowedKeys = [
    "system"
    "hostName"
    "user"
    "roles"
    "features"
    "hardware"
    "stateVersion"
    "homeStateVersion"
    "extraModules"
    "extraGroups"
    "allowedUnfree"
    "mutableUsers"
  ];

  requiredKeys = [
    "roles"
    "stateVersion"
    "homeStateVersion"
    "hardware"
    "features"
  ];
}
