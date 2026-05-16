{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.shellcheck ];
}
