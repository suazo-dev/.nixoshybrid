{ lib, pkgs, spec, ... }:
let
  hasRole = role: builtins.elem role spec.roles;
in {
  # System config goes here.
  # Example:
  # environment.systemPackages = with pkgs; [ ];
  # lib.mkIf (hasRole "gateway") { ... }
  # lib.mkIf (hasRole "portal") { ... }

  home-manager.users.${spec.user} = { ... }: {
    # User config goes here.

    # Use xdg.configFile for files under ~/.config/...
    # Example:
    # xdg.configFile."ghostty/config".source = ./dotfiles/ghostty/config;
    # xdg.configFile."niri/config.kdl".source = ./dotfiles/niri/config.kdl;

    # Use home.file for files directly in $HOME or elsewhere.
    # Example:
    # home.file.".zshrc".source = ./dotfiles/.zshrc;
    # home.file.".gitconfig".source = ./dotfiles/.gitconfig;
  };
}
