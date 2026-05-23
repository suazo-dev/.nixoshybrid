{ pkgs, spec, ... }:
{
  programs.zsh.enable = true;
  users.users.${spec.user}.shell = pkgs.zsh;
}
