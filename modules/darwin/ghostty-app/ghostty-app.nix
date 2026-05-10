{ lib, spec, ... }:
let
  ghosttyRoot = "${spec.repoRoot}/modules/gui/ghostty/dotfiles/ghostty";
in {
  environment.variables = lib.mkIf (!spec.facts.headless) {
    TERMINAL = "ghostty";
  };

  homebrew.casks = lib.mkIf (!spec.facts.headless) [ "ghostty" ];

  home-manager.users.${spec.user} = lib.mkIf (!spec.facts.headless) ({ config, ... }: {
    home.file."Library/Application Support/com.mitchellh.ghostty/config".source =
      config.lib.file.mkOutOfStoreSymlink "${ghosttyRoot}/config";
    home.file."Library/Application Support/com.mitchellh.ghostty/themes".source =
      config.lib.file.mkOutOfStoreSymlink "${ghosttyRoot}/themes";
  });
}
