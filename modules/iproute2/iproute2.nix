{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.iproute2 ];
}
