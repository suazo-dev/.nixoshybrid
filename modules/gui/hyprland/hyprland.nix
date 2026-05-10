{ lib, pkgs, spec, ... }:
{
  programs.hyprland.enable = lib.mkIf (!spec.facts.headless) true;

  environment.systemPackages = lib.mkIf (!spec.facts.headless) [
    pkgs.xdg-desktop-portal-hyprland
  ];

  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({ ... }: {
    xdg.configFile."hypr".source = ./dotfiles/hypr;
  });
}
