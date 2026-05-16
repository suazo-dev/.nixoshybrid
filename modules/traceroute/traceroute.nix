{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.traceroute ];
}
