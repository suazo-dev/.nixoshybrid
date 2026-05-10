{ lib, spec, ... }:
{
  services.upower.enable =
    if builtins.elem "core" spec.roles
    then lib.mkForce false
    else lib.mkIf (!spec.facts.headless) true;
}
