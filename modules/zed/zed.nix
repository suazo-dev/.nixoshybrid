{
  lib,
  pkgs,
  spec,
  ...
}: {
  environment.systemPackages = lib.mkIf (!spec.facts.headless) [pkgs.zed-editor];

  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({config, ...}: {
    xdg.configFile."zed/themes/Catppuccin Black.json".source =
      config.lib.file.mkOutOfStoreSymlink
      "${spec.repoRoot}/modules/gui/zed/dotfiles/Catppuccin Black.json";
  });
}
