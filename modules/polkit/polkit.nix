{ lib, spec, ... }:
{
  security.polkit.enable = lib.mkIf (!spec.facts.headless) true;
}
