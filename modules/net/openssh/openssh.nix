{ lib, spec, ... }:
let
  isDarwin = lib.hasSuffix "-darwin" spec.system;
in {
  services.openssh.enable = true;

  services.openssh.settings = lib.mkIf (!isDarwin) {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PubkeyAuthentication = true;
    X11Forwarding = false;
    TCPKeepAlive = true;
    ClientAliveInterval = 30;
    ClientAliveCountMax = 6;
  };

  services.openssh.extraConfig = lib.mkIf isDarwin ''
    PermitRootLogin no
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    PubkeyAuthentication yes
    X11Forwarding no
    TCPKeepAlive yes
    ClientAliveInterval 30
    ClientAliveCountMax 6
  '';
}
