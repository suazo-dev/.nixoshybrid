{ lib, spec, ... }:
let
  enabled = builtins.elem "core" (spec.roles or [ ]) && !(spec.facts.headless or false);
in {
  system.activationScripts.postActivation.text = lib.mkAfter ''
    if ${if enabled then "true" else "false"}; then
      launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
    else
      launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
    fi
  '';
}
