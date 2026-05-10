{ lib, spec }:
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) spec.allowedUnfree;
}
