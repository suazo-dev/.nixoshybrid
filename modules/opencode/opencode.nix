{
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.opencode];
}
