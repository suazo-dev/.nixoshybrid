{ lib, pkgs, spec, ... }:
{
  services.gnome.gnome-keyring.enable = lib.mkIf (!spec.facts.headless) true;
  environment.systemPackages = lib.mkIf (!spec.facts.headless) [ pkgs.gnome-keyring ];
}
