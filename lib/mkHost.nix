{
  inputs,
  lib,
}: machineName:
let
  root = ../.;
  defaults = import ./defaults.nix;
  schema = import ./schema.nix { inherit lib; };
  registry = import ../network/registry.nix;
  base = import ../nodes/base.nix;

  machinePath = root + "/machines/${machineName}/default.nix";
  machineFactsPath = root + "/machines/${machineName}/facts.nix";

  rawMachine = import machinePath;
  checkedMachine = schema.validateMachine machineName rawMachine;

  nodeName = checkedMachine.nodeName;
  instanceName = checkedMachine.instanceName;
  nodePath = root + "/nodes/${nodeName}.nix";
  nodeSpec = schema.validateNode nodeName (import nodePath);

  machineFacts =
    if builtins.pathExists machineFactsPath then
      import machineFactsPath
    else
      { };

  machineSystem = checkedMachine.system or defaults.system;
  isDarwin = lib.hasSuffix "-darwin" machineSystem;
  systemClass = if isDarwin then "darwin" else "linux";

  _systemCheck =
    if builtins.elem systemClass nodeSpec.supportedSystems then
      null
    else
      throw "Machine '${machineName}' (${machineSystem}) cannot use node '${nodeName}' (${lib.concatStringsSep ", " nodeSpec.supportedSystems})";

  registryMachine = registry.machines.${machineName} or (throw "Registry is missing machine '${machineName}'");

  validatedFacts = schema.validateFacts machineName (lib.recursiveUpdate machineFacts (nodeSpec.facts or { }));

  facts = lib.recursiveUpdate validatedFacts {
    network = {
      lanInterface = registryMachine.lan.interface or null;
      wakeMac = registryMachine.lan.wakeMac or null;
    };
  };

  defaultExtraGroups = if isDarwin then [ ] else (defaults.extraGroups or [ ]);

  # Base modules minus node removals
  nodeRemove = nodeSpec.remove or [ ];
  nodeRemoveLinux = nodeSpec.removeLinux or [ ];
  nodeRemoveDarwin = nodeSpec.removeDarwin or [ ];

  baseModules = builtins.filter (m: !(builtins.elem m nodeRemove)) (base.modules or [ ]);
  baseLinuxModules = builtins.filter (m:
    !(builtins.elem m nodeRemove) && !(builtins.elem m nodeRemoveLinux)
  ) (base.linuxModules or [ ]);
  baseDarwinModules = builtins.filter (m:
    !(builtins.elem m nodeRemove) && !(builtins.elem m nodeRemoveDarwin)
  ) (base.darwinModules or [ ]);

  moduleNames = lib.unique (
    baseModules
    ++ (if isDarwin then baseDarwinModules else baseLinuxModules)
    ++ (checkedMachine.extraModules or [ ])
  );

  baseSpec = defaults // checkedMachine // {
    hostName = checkedMachine.hostName;
    roles = registryMachine.roles or [ nodeName ];
    allowedUnfree = lib.unique (
      (defaults.allowedUnfree or [ ])
      ++ (checkedMachine.allowedUnfree or [ ])
      ++ (base.allowedUnfree or [ ])
    );
    extraGroups = lib.unique (
      defaultExtraGroups
      ++ (checkedMachine.extraGroups or [ ])
    );
    mutableUsers =
      if checkedMachine ? mutableUsers then
        checkedMachine.mutableUsers
      else
        defaults.mutableUsers;
    system = machineSystem;
    facts = facts;
    machineName = machineName;
    nodeName = nodeName;
    instanceName = instanceName;
    secretFileName = registryMachine.secretFileName;
    modules = moduleNames;
  };

  homeDirectory = if isDarwin then "/Users/${baseSpec.user}" else "/home/${baseSpec.user}";
  repoRoot = "${homeDirectory}/${defaults.repoDirName or ".nixoshybrid"}";
  spec = baseSpec // {
    inherit homeDirectory repoRoot;
  };

  sshAuthorizedKeys = map (name: registry.sshKeys.${name}) (registryMachine.sshAuthorizedKeys or [ ]);

  moduleResolver = import ./resolve/modules.nix {
    root = root;
    inherit machineName;
  };

  modulePaths = moduleResolver.paths spec.modules;
  hardwarePath = root + "/machines/${machineName}/${checkedMachine.hardware}";

  hostsModule =
    if isDarwin then
      { }
    else
      (import (root + "/network/hosts.nix") { inherit lib; }).mkHostsModule machineName;

  userModule =
    if isDarwin then
      {
        users.users.${spec.user}.home = homeDirectory;

        system.activationScripts.postActivation.text = lib.mkIf (sshAuthorizedKeys != [ ]) ''
          mkdir -p ${homeDirectory}/.ssh
          printf '%s\n' ${lib.concatStringsSep " " (map (k: "'${k}'") sshAuthorizedKeys)} > ${homeDirectory}/.ssh/authorized_keys
          chown ${spec.user} ${homeDirectory}/.ssh ${homeDirectory}/.ssh/authorized_keys
          chmod 700 ${homeDirectory}/.ssh
          chmod 600 ${homeDirectory}/.ssh/authorized_keys
        '';
      }
    else {
      users.mutableUsers = spec.mutableUsers;

      users.users.${spec.user} = {
        isNormalUser = true;
        extraGroups = spec.extraGroups;
        openssh.authorizedKeys.keys = sshAuthorizedKeys;
      };
    };

  hostCoreModule = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";
    home-manager.extraSpecialArgs = {
      inherit spec machineName inputs;
    };

    home-manager.users.${spec.user} = { ... }: {
      home.username = spec.user;
      home.homeDirectory = homeDirectory;
      home.stateVersion = spec.homeStateVersion;
    };
  } // (if isDarwin then {
    networking.hostName = spec.hostName;
    networking.computerName = spec.hostName;
    networking.localHostName = spec.hostName;
    system.primaryUser = spec.user;
    system.stateVersion = builtins.fromJSON spec.stateVersion;
  } else {
    networking.hostName = spec.hostName;
    system.stateVersion = spec.stateVersion;
  });

  unfreeModule = import ./resolve/unfree.nix { inherit lib spec; };
in
  (if isDarwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem) {
    system = spec.system;
    specialArgs = {
      inherit inputs spec machineName;
    };
    modules =
      [
        (if isDarwin then inputs.home-manager.darwinModules.home-manager else inputs.home-manager.nixosModules.home-manager)
        userModule
        hostCoreModule
        hostsModule
        unfreeModule
      ]
      ++ lib.optional (builtins.pathExists hardwarePath) hardwarePath
      ++ modulePaths;
  }
