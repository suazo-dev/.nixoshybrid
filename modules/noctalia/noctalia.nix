{lib, pkgs, spec, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  environment.systemPackages = lib.mkIf (!spec.facts.headless) [
    inputs.noctalia.packages.${system}.default
  ];

  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({ config, ... }: {
    xdg.configFile."noctalia".source =
      config.lib.file.mkOutOfStoreSymlink
        "${spec.repoRoot}/modules/noctalia/dotfiles/noctalia";
  });
}
