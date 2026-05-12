{ ... }:
{
  system.activationScripts.postActivation.text = ''
    launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
  '';
}
