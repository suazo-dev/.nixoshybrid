{ lib, spec, machineName, ... }:
let
  isDarwin = lib.hasSuffix "-darwin" spec.system;
  registry = import ../../network/registry.nix;

  # Build SSH client host entries for all known machines
  allMachines = registry.machines;
  internalHosts = lib.concatMapStrings (name:
    let machine = allMachines.${name};
    in lib.optionalString (name != machineName) ''
      Host ${machine.hostName} ${machine.wg.core.ip or ""}
        IdentityFile ~/.ssh/id_ed25519
        ForwardAgent yes
        StrictHostKeyChecking accept-new
    ''
  ) (builtins.attrNames allMachines);
in {
  services.openssh = {
    enable = true;
  } // lib.optionalAttrs (!isDarwin) {
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;
      X11Forwarding = false;
      TCPKeepAlive = true;
      ClientAliveInterval = 30;
      ClientAliveCountMax = 6;
    };
  } // lib.optionalAttrs isDarwin {
    extraConfig = ''
      PermitRootLogin no
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      PubkeyAuthentication yes
      X11Forwarding no
      TCPKeepAlive yes
      ClientAliveInterval 30
      ClientAliveCountMax 6
    '';
  };

  # SSH client config — ensures key is loaded and agent forwarding works
  home-manager.users.${spec.user} = { ... }: {
    programs.ssh = {
      enable = true;
      addKeysToAgent = if isDarwin then "yes" else "confirm";
      extraConfig = lib.optionalString isDarwin ''
        UseKeychain yes
      '';
      matchBlocks = {
        "internal" = {
          host = lib.concatStringsSep " " (
            lib.concatMap (name:
              let machine = allMachines.${name};
              in lib.optional (name != machineName) machine.hostName
            ) (builtins.attrNames allMachines)
          );
          identityFile = "~/.ssh/id_ed25519";
          forwardAgent = true;
          extraOptions.StrictHostKeyChecking = "accept-new";
        };
      };
    };
  };
}
