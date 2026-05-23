{ pkgs, spec, lib, ... }:
let
  hasRole = role: builtins.elem role spec.roles;
  isDarwin = lib.hasSuffix "-darwin" spec.system;
  alwaysOn = hasRole "gateway" || hasRole "core" || hasRole "storage";
  n = spec.facts.network or { };
  wolInterface = n.lanInterface or null;
in lib.mkIf alwaysOn (
  if isDarwin then {
    power = {
      sleep.computer = "never";
      sleep.display = 15;
      sleep.harddisk = "never";
};
  } else {
    environment.systemPackages = [ pkgs.wakeonlan pkgs.ethtool ];

    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
      IdleAction = "ignore";
      HandleSuspendKey = "ignore";
      HandleHibernateKey = "ignore";
    };

    systemd.services.enable-wake-on-lan = lib.mkIf (wolInterface != null) {
      description = "Enable Wake-on-LAN";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-pre.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.ethtool}/bin/ethtool -s ${wolInterface} wol g";
      };
    };
  }
)
