{ pkgs, spec, lib, ... }:
let
  hasRole = role: builtins.elem role spec.roles;
in lib.mkIf (hasRole "portal") {
  environment.systemPackages = [ pkgs.remmina ];
}
