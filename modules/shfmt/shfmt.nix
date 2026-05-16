{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.shfmt ];
}
