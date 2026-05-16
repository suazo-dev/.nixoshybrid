{ pkgs, lib, spec, ... }:
{
  environment.systemPackages =
    lib.mkIf (!spec.facts.headless && spec.facts.theme.cursor.package == "bibata-cursors")
      [ pkgs.bibata-cursors ];

  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({ ... }: {
    gtk.cursorTheme = {
      name = spec.facts.theme.cursor.name;
      package = pkgs.bibata-cursors;
      size = spec.facts.theme.cursor.size;
    };

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = spec.facts.theme.cursor.name;
      size = spec.facts.theme.cursor.size;
    };

    home.sessionVariables = {
      XCURSOR_THEME = spec.facts.theme.cursor.name;
      XCURSOR_SIZE = builtins.toString spec.facts.theme.cursor.size;
    };
  });
}
