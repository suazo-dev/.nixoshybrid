{ lib, spec, ... }:
{
  programs.niri.enable = lib.mkIf (!spec.facts.headless) true;

  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({ config, ... }: {
    xdg.configFile."niri".source =
      config.lib.file.mkOutOfStoreSymlink
      "${spec.repoRoot}/modules/gui/niri/dotfiles/niri";
  });
}
