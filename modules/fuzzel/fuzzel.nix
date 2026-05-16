{
  lib,
  pkgs,
  spec,
  ...
}: {
  environment.systemPackages = lib.mkIf (!spec.facts.headless) [ pkgs.fuzzel ];

  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({config, ...}: {
    xdg.configFile."fuzzel".source =
      config.lib.file.mkOutOfStoreSymlink
      "${spec.repoRoot}/modules/gui/fuzzel/dotfiles/fuzzel";
  });
}
