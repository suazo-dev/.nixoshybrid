{ lib, spec, ... }:
{
  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({ ... }: {
    xdg.configFile."backgrounds".source = ./dotfiles/backgrounds;
  });
}
