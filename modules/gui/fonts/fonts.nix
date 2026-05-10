{ lib, pkgs, spec, ... }:
let
  isDarwin = lib.hasSuffix "-darwin" spec.system;
  fontPackages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ];
in {
  fonts = lib.mkIf (!spec.facts.headless) (
    {
      packages = fontPackages;
    }
    // lib.optionalAttrs (!isDarwin) {
      fontconfig.defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    }
  );
}
