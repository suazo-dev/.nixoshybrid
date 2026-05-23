# Hermes Agent module.
# The storage node runs the Hermes gateway inside OCI container mode, exposes
# the OpenAI-compatible API server, and can also run Telegram from the same
# gateway. Other machines only get the CLI package.
{ lib, pkgs, inputs, spec, machineName, config, ... }:
let
  registry = import ../../network/registry.nix;
  nodeRoot = ../../nodes;
  isDarwin = lib.hasSuffix "-darwin" spec.system;
  isLinux = !isDarwin;
  isHermesHost = spec.facts.hermes.gateway or false;
  hermesHostName = lib.findFirst (name:
    let
      m = registry.machines.${name};
      node = import (nodeRoot + "/${m.nodeName}.nix");
    in node.facts.hermes.gateway or false
  ) (throw "No machine with hermes.gateway fact found") registry.machineNames;
  hermesMachine = registry.machines.${hermesHostName};
  hermesIp = hermesMachine.wg.core.ip;
  hermesApiPort = 8642;
  dashboardPort = 9119;
  envSecretName = "hermes/runtime-env";
  authSecretName = "hermes/auth-json";
  hermesPackage = inputs.hermes-agent.packages.${spec.system}.default.override {
    extraDependencyGroups = [ "messaging" ];
  };
  remoteTuiPackage = pkgs.writeShellScriptBin "hermes-${hermesHostName}" ''
    set -euo pipefail

    dashboard_url="http://${hermesIp}:${toString dashboardPort}"
    html="$(curl -fsSL "$dashboard_url/")"
    token="$(printf '%s' "$html" | rg -o 'window\.__HERMES_SESSION_TOKEN__="([^"]+)"' -r '$1' -N -m1)"

    if [ -z "$token" ]; then
      printf '%s\n' "Failed to extract Hermes dashboard session token from $dashboard_url" >&2
      printf '%s\n' "Make sure the dashboard is enabled on ${hermesHostName} and reachable over WireGuard." >&2
      exit 1
    fi

    export HERMES_TUI_GATEWAY_URL="ws://${hermesIp}:${toString dashboardPort}/api/ws?token=$token"
    exec hermes --tui "$@"
  '';
in {
  imports = lib.optionals isHermesHost [ inputs.hermes-agent.nixosModules.default ];

  environment.systemPackages = lib.mkIf (!isHermesHost) [
    inputs.hermes-agent.packages.${spec.system}.default
    remoteTuiPackage
  ];
} // lib.optionalAttrs isHermesHost {
  # One env file for gateway runtime secrets/settings. Suggested contents:
  #   API_SERVER_KEY=strong-random-string  # required for 0.0.0.0 binds
  #   TELEGRAM_BOT_TOKEN=123456:telegram-token
  #   TELEGRAM_ALLOWED_USERS=123456789
  # Optional extras if you want them later:
  #   TELEGRAM_GROUP_ALLOWED_CHATS=-1001234567890
  #   TELEGRAM_GUEST_MODE=true
  sops.secrets.${envSecretName} = {
    owner = "root";
    group = "root";
    mode = "0400";
    path = "/run/secrets/hermes-runtime.env";
  };

  # Seed Hermes' auth store for the openai-codex provider. Populate this with
  # the contents of ~/.hermes/auth.json after `hermes auth add openai-codex` on
  # a machine where you can complete the device-code login flow.
  sops.secrets.${authSecretName} = {
    owner = "root";
    group = "root";
    mode = "0400";
    path = "/run/secrets/hermes-auth.json";
  };

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    package = hermesPackage;
    environmentFiles = [ config.sops.secrets.${envSecretName}.path ];
    authFile = config.sops.secrets.${authSecretName}.path;

    container = {
      enable = true;
      image = "ubuntu:24.04";
      hostUsers = [ spec.user ];
    };

    settings = {
      model = {
        provider = "openai-codex";
        default = "gpt-5.5";
      };

      toolsets = [ "all" ];

      terminal = {
        backend = "local";
        timeout = 180;
      };

      gateway = {
        streaming = {
          enabled = true;
          transport = "edit";
        };

        platforms.telegram.extra = {
          disable_link_previews = true;
        };
      };

      display.platforms.telegram.notifications = "important";
    };

    environment = {
      API_SERVER_ENABLED = "true";
      API_SERVER_HOST = "0.0.0.0";
      API_SERVER_PORT = toString hermesApiPort;
      API_SERVER_MODEL_NAME = "hermes-agent";
    };
  };

  security.sudo.extraRules = [{
    users = [ spec.user ];
    commands = [{
      command = "/run/current-system/sw/bin/docker";
      options = [ "NOPASSWD" ];
    }];
  }];

  systemd.services.hermes-agent-dashboard = {
    description = "Hermes Agent Web UI (container)";
    wantedBy = [ "multi-user.target" ];
    after = [ "hermes-agent.service" ];
    wants = [ "hermes-agent.service" ];
    requires = [ "hermes-agent.service" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      ExecStart = ''
        /run/current-system/sw/bin/docker exec \
          --interactive \
          --user hermes \
          --env HOME=/home/hermes \
          --env HERMES_HOME=/data/.hermes \
          --env HERMES_DASHBOARD_TUI=1 \
          hermes-agent \
          /data/current-package/bin/hermes dashboard --host 0.0.0.0 --port ${toString dashboardPort} --tui --skip-build --no-open --insecure
      '';
      ExecStop = "/run/current-system/sw/bin/docker exec --user hermes hermes-agent /data/current-package/bin/hermes dashboard --stop";
    };
  };
}
