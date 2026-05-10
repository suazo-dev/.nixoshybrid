{ pkgs, lib, spec, ... }:
{
  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({ ... }: {
    gtk.iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  });
}
