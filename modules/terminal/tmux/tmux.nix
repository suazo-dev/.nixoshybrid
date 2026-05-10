{ pkgs, spec, ... }:
{
  environment.systemPackages = [ pkgs.tmux ];

  home-manager.users.${spec.user} = { ... }: {
    xdg.configFile."tmux".source = ./dotfiles/tmux;
  };
}
