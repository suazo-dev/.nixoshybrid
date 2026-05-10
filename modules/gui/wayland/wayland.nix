{ lib, pkgs, spec, ... }:
{
  xdg.portal = lib.mkIf (!spec.facts.headless) {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  environment.sessionVariables = lib.mkIf (!spec.facts.headless) {
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    XCURSOR_THEME = spec.facts.theme.cursor.name;
    XCURSOR_SIZE = builtins.toString spec.facts.theme.cursor.size;
  };
}
