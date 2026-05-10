{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.direnv ];
  programs.direnv.enable = true;
}
