{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.nodePackages.bash-language-server ];
}
