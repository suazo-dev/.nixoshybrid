{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.gawk ];
}
