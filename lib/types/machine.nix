{
  allowedKeys = [
    "hostName"
    "system"
    "nodeName"
    "instanceName"
    "user"
    "hardware"
    "stateVersion"
    "homeStateVersion"
    "extraModules"
    "extraGroups"
    "allowedUnfree"
    "mutableUsers"
    "lan"
    "wgPublicKeys"
    "sshPublicKey"
  ];

  requiredKeys = [
    "hostName"
    "nodeName"
    "instanceName"
    "stateVersion"
    "homeStateVersion"
    "hardware"
  ];
}
