{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.gnugrep ];
}
