{
  supportedSystems = [ "linux" "darwin" ];

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
  ];

  darwinModules = [
    "ghostty-app"
    "aerospace"
    "sketchybar"
    "storage-mount"
    "screen-sharing"
    "firewall"
  ];

  network = {
    wg = {
      core = { octet = 3; };
    };
  };

  facts = {
    storage.nfs = {
      mountPoint = "/Volumes/storage";
    };
  };
}
