{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.nmap ];
}
