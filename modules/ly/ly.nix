{ lib, spec, ... }:
{
  services.displayManager.ly.enable = lib.mkIf (!spec.facts.headless) true;
}
