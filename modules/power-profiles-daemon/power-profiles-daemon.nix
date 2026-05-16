{ lib, spec, ... }:
{
  services.power-profiles-daemon.enable = lib.mkIf (!spec.facts.headless) true;
}
