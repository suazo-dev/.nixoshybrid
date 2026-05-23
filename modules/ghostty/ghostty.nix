{ lib, pkgs, spec, ... }:
{
  environment.systemPackages = lib.mkIf (!spec.facts.headless) [ pkgs.ghostty ];

  environment.sessionVariables = lib.mkIf (!spec.facts.headless) {
    TERMINAL = "ghostty";
  };

  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({ config, ... }: {
    xdg.configFile."ghostty".source =
      config.lib.file.mkOutOfStoreSymlink
      "${spec.repoRoot}/modules/ghostty/dotfiles/ghostty";
  });
}
