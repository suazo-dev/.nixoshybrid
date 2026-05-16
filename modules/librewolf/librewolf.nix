{ lib, pkgs, spec, ... }:
{
  environment.systemPackages = lib.mkIf (!spec.facts.headless) [ pkgs.librewolf ];

  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({ ... }: {
    home.sessionVariables.BROWSER = "librewolf";
  });
}
