{
  lib,
  spec,
  ...
}: {
  hardware.bluetooth = lib.mkIf (!spec.facts.headless) {
    enable = true;
    #powerOnBoot = true;
  };

  services.blueman.enable = lib.mkIf (!spec.facts.headless) true;
}
