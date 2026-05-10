{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.wireshark-cli ];
}
