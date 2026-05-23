# Hermes Agent module.
# mama is the single Hermes host. It runs the gateway inside Hermes' OCI
# container mode, exposes the OpenAI-compatible API server, and can also run
# Telegram from the same gateway. Other machines only get the CLI package.
{ lib, inputs, spec, machineName, config, ... }:
let
  registry = import ../../network/registry.nix;
  isDarwin = lib.hasSuffix "-darwin" spec.system;
  isLinux = !isDarwin;
  gatewayMachineName = "mama";
  isGatewayHost = isLinux && machineName == gatewayMachineName;
  gatewayMachine = registry.machines.${gatewayMachineName};
  gatewayIp = gatewayMachine.wg.core.ip;
  gatewayPort = 8642;
  envSecretName = "hermes/runtime-env";
  authSecretName = "hermes/auth-json";
in {
  imports = lib.optionals isGatewayHost [ inputs.hermes-agent.nixosModules.default ];

  environment.systemPackages = lib.mkIf (!isGatewayHost) [
    inputs.hermes-agent.packages.${spec.system}.default
  ];
} // lib.optionalAttrs isGatewayHost {
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
      API_SERVER_PORT = toString gatewayPort;
      API_SERVER_MODEL_NAME = "hermes-agent";
    };
  };
}
