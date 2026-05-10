{
  inputs,
  lib,
}: machineName: let
  root = ../.;
  defaults = import ./defaults.nix;
  schema = import ./schema.nix {inherit lib;};
  registry = import ../network/registry.nix;

  machinePath = root + "/machines/${machineName}/default.nix";
  factsPath = root + "/machines/${machineName}/facts.nix";

  rawMachine = import machinePath;
  checkedMachine = schema.validateMachine machineName rawMachine;

  rawFacts =
    if builtins.pathExists factsPath
    then import factsPath
    else {};
  facts = schema.validateFacts machineName rawFacts;

  machineSystem = checkedMachine.system or defaults.system;
  isDarwin = lib.hasSuffix "-darwin" machineSystem;
  defaultFeatures = if isDarwin then [ ] else (defaults.features or [ ]);
  defaultExtraGroups = if isDarwin then [ ] else (defaults.extraGroups or [ ]);
  hostName = checkedMachine.hostName or machineName;

  baseSpec =
    defaults
    // checkedMachine
    // {
      inherit hostName;
      features =
        lib.unique (defaultFeatures ++ (checkedMachine.features or []));
      extraModules = checkedMachine.extraModules or [];
      extraGroups =
        lib.unique (defaultExtraGroups ++ (checkedMachine.extraGroups or []));
      allowedUnfree =
        lib.unique ((defaults.allowedUnfree or []) ++ (checkedMachine.allowedUnfree or []));
      roles = lib.unique ((defaults.roles or []) ++ (checkedMachine.roles or []));
      mutableUsers = checkedMachine.mutableUsers or defaults.mutableUsers;
      system = machineSystem;
      facts = facts;
    };
  homeDirectory = if isDarwin then "/Users/${baseSpec.user}" else "/home/${baseSpec.user}";
  repoRoot = "${homeDirectory}/${defaults.repoDirName or ".nixoshybrid"}";
  spec = baseSpec // {
    inherit homeDirectory repoRoot;
  };

  # Resolve SSH keys from registry
  registryMachine = registry.machines.${machineName} or {};
  sshKeyNames = registryMachine.sshAuthorizedKeys or [];
  sshAuthorizedKeys = map (name: registry.sshKeys.${name}) sshKeyNames;

  featureResolver = import ./resolve/features.nix {
    inherit lib schema machineName;
    root = root;
  };

  moduleResolver = import ./resolve/modules.nix {
    root = root;
    inherit machineName;
  };

  resolvedFeatures = featureResolver.resolve spec.features;

  moduleNames = lib.unique (
    lib.concatLists (
      map
      (f:
        (f.modules or [])
        ++ (if isDarwin then (f.darwinModules or []) else (f.linuxModules or [])))
      resolvedFeatures.features
    )
    ++ spec.extraModules
  );

  modulePaths = moduleResolver.paths moduleNames;
  hardwarePath = root + "/machines/${machineName}/${spec.hardware}";

  hostsModule =
    if isDarwin then
      { }
    else
      (import (root + "/network/hosts.nix") { inherit lib; }).mkHostsModule machineName;

  userModule =
    if isDarwin then
      {
        users.users.${spec.user}.home = homeDirectory;

        home-manager.users.${spec.user} = lib.mkIf (sshAuthorizedKeys != [ ]) ({ ... }: {
          home.file.".ssh/authorized_keys".text = lib.concatStringsSep "\n" sshAuthorizedKeys + "\n";
        });
      }
    else {
      users.mutableUsers = spec.mutableUsers;

      users.users.${spec.user} = {
        isNormalUser = true;
        extraGroups = spec.extraGroups;
        openssh.authorizedKeys.keys = sshAuthorizedKeys;
      };
    };

  hostCoreModule =
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {
        inherit spec machineName inputs;
      };

      home-manager.users.${spec.user} = {...}: {
        home.username = spec.user;
        home.homeDirectory = homeDirectory;
        home.stateVersion = spec.homeStateVersion;
      };
    }
    // (if isDarwin then {
      networking.hostName = hostName;
      networking.computerName = hostName;
      networking.localHostName = hostName;
      system.primaryUser = spec.user;
      system.stateVersion = builtins.fromJSON spec.stateVersion;
    } else {
      networking.hostName = hostName;
      system.stateVersion = spec.stateVersion;
    });

  unfreeModule = import ./resolve/unfree.nix {inherit lib spec;};
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
