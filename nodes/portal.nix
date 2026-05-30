{
  supportedSystems = [ "linux" ];

  modules = [
    "fonts"
    "librewolf"
    "firefox"
    "zed"
    "claude-code"
    "nvf"
    "helix"
    "opencode"
    "lazygit"
    "direnv"
    "devenv"
    "just"
    "mise"
    "nil"
    "nixd"
    "lua-language-server"
    "bash-language-server"
    "shellcheck"
    "shfmt"
    "tree-sitter"
  ];

  linuxModules = [
    "remmina"
    "pipewire"
    "bluetooth"
    "fuzzel"
    "ly"
    "adwaita-dark"
    "papirus"
    "bibata"
    "wallpapers"
    "zen-browser"
    "ghostty"
    "niri"
    "kde"
    "quickshell"
    "noctalia"
    "mako"
    "polkit-gnome"
    "xwayland-satellite"
    "swww"
    "waybar"
    "wl-clipboard"
    "wayland"
    "grim"
    "slurp"
    "brightnessctl"
    "pavucontrol"
    "playerctl"
    "gnome-keyring"
    "power-profiles-daemon"
    "upower"
    "networkmanagerapplet"
    "intel"
    "nix-ld"
    "networkmanager"
    "iwd"
  ];

  network = {
    wg = {
      portal = { octet = 2; };
    };
  };

  facts = {
    network = {
      useNetworkManager = true;
      useIwd = true;
    };
  };
}
