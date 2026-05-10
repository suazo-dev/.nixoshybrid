{ lib, spec, ... }:
let
  isDarwin = lib.hasSuffix "-darwin" spec.system;
in {
  services.openssh.enable = true;
}
// (if isDarwin then {
  services.openssh.extraConfig = ''
    PermitRootLogin no
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    PubkeyAuthentication yes
    X11Forwarding no
    TCPKeepAlive yes
    ClientAliveInterval 30
    ClientAliveCountMax 6
  '';
} else {
  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PubkeyAuthentication = true;
    X11Forwarding = false;
    TCPKeepAlive = true;
    ClientAliveInterval = 30;
    ClientAliveCountMax = 6;
  };
})
