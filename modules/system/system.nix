{ pkgs, ... }:
{
  environment.shells = [ pkgs.zsh ];
  security.pam.services.sudo_local.touchIdAuth = true;
}
