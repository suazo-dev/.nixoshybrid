{ pkgs, spec, ... }:
{
  environment.systemPackages = [ pkgs.starship ];

  home-manager.users.${spec.user} = { ... }: {
    xdg.configFile."starship.toml".source = ./dotfiles/starship.toml;
  };
}
