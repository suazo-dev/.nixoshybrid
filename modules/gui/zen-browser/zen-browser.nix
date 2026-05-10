{ lib, pkgs, spec, inputs, ... }:
{
  environment.systemPackages = lib.mkIf (!spec.facts.headless) [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
