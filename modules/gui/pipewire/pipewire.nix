{ lib, spec, ... }:
{
  services.pipewire = lib.mkIf (!spec.facts.headless) {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  security.rtkit.enable = lib.mkIf (!spec.facts.headless) true;
}
