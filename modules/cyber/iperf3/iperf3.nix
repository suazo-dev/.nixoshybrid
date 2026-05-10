{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.iperf3 ];
}
