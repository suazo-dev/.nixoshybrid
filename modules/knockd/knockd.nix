# Port knocking — emergency LAN SSH access for gateway.
# Sends a knock sequence to temporarily open SSH from that LAN IP (60s).
# Tiny's nftables emergency_ssh_sources set auto-expires the entry.
{ lib, pkgs, spec, machineName, ... }:
let
  registry = import ../../network/registry.nix;
  knockd = pkgs.callPackage ./package.nix { };
  isGateway = spec.nodeName == "gateway";
  lanInterface =
    let iface = (registry.machines.${machineName}.lan or {}).interface or null;
    in if isGateway && iface == null
       then throw "Gateway machine '${machineName}' must have 'lan.interface' set for knockd"
       else iface;

  knockdConf = pkgs.writeText "knockd.conf" ''
    [options]
    logfile     = /var/log/knockd.log
    interface   = ${lanInterface}

    [openSSH]
    sequence      = 7000,8000,9000
    seq_timeout   = 10
    tcpflags      = syn
    start_command = ${pkgs.nftables}/bin/nft add element inet gateway emergency_ssh_sources { %IP% timeout 60s }
  '';
in {
  environment.systemPackages = [ knockd ];

  systemd.services.knockd = lib.mkIf isGateway {
    description = "Port knocking daemon — emergency LAN SSH access";
    after = [ "network.target" "nftables.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${knockd}/bin/knockd -d -c ${knockdConf}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
