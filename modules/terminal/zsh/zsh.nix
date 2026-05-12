{ pkgs, spec, lib, machineName, ... }:
let
  hasRole = role: builtins.elem role spec.roles;
  isDarwin = lib.hasSuffix "-darwin" spec.system;
  hosts = import ../../../network/hosts.nix { inherit lib; };
  sshKeepalive = {
    user = spec.user;
    serverAliveInterval = 30;
    serverAliveCountMax = 6;
  };
  registryMatchBlocks = lib.mapAttrs
    (host: hostname: sshKeepalive // {
      inherit host hostname;
    })
    (hosts.hostsFor machineName);
in
{
  programs.zsh.enableCompletion = false;

  environment.systemPackages =
    [ pkgs.zsh ]
    ++ lib.optionals (!isDarwin) [ pkgs.ghostty.terminfo ]
    ++ lib.optionals (hasRole "portal") [ pkgs.wakeonlan ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    NIXCFG_ROOT = spec.repoRoot;
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  home-manager.users.${spec.user} = { ... }: {
    home.file.".zshrc".source = ./dotfiles/.zshrc;
    xdg.configFile = {
      "zsh/host-flags.zsh".text = ''
        export ZSH_HOST_HEADLESS=${if spec.facts.headless or false then "1" else "0"}
        export ZSH_HOST_CORE=${if hasRole "core" then "1" else "0"}
        export ZSH_HOST_PORTAL=${if hasRole "portal" then "1" else "0"}
        export ZSH_HOST_GATEWAY=${if hasRole "gateway" then "1" else "0"}
      '';
    } // lib.optionalAttrs (!isDarwin && hasRole "core") {
      "autostart/org_kde_powerdevil.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=PowerDevil
        Hidden=true
      '';
    };
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {};
      } // registryMatchBlocks;
    };

  };
}
