{
  lib,
  pkgs,
  spec,
  ...
}: {
  environment.systemPackages = lib.mkIf (!spec.facts.headless) [pkgs.fastfetch];

  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({config, ...}: {
    xdg.configFile."fastfetch/config.jsonc".source =
      config.lib.file.mkOutOfStoreSymlink
      "${spec.repoRoot}/modules/terminal/fastfetch/dotfiles/fastfetch/config.jsonc";
  });
}
