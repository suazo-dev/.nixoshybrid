{ lib, pkgs, spec, ... }:
{
  services.desktopManager.plasma6.enable = lib.mkIf (!spec.facts.headless) true;

  environment.systemPackages = lib.mkIf (!spec.facts.headless) (with pkgs; [
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.spectacle
    kdePackages.kate
  ]);
}
