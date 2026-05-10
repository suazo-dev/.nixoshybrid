{ lib, spec, ... }:
let
  isDarwin = lib.hasSuffix "-darwin" spec.system;
in {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    warn-dirty = false;
  };

  nix.gc = if isDarwin then {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 3;
      Minute = 15;
    };
    options = "--delete-older-than 14d";
  } else {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
