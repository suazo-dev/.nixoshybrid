{ lib, pkgs, spec, ... }:
{
  hardware.graphics = lib.mkIf (!spec.facts.headless) {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  hardware.enableRedistributableFirmware = lib.mkIf (!spec.facts.headless) true;

  environment.sessionVariables = lib.mkIf (!spec.facts.headless) {
    LIBVA_DRIVER_NAME = "iHD";
  };

  boot.kernelParams = lib.mkIf (!spec.facts.headless) [
    "i915.enable_guc=3"
  ];
}
