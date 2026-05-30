# Single source of truth for universal modules.
# Every machine gets these. Nodes add role-specific modules via their own
# `modules`, `linuxModules`, and `darwinModules` keys.
{
  modules = [
    "user"
    "nix"
    "git"
    "tcpdump"
    "nmap"
    "dnsutils"
    "iperf3"
    "wireshark-cli"
    "zsh"
    "nushell"
    "starship"
    "tmux"
    "yazi"
    "fastfetch"
    "ripgrep"
    "fd"
    "fzf"
    "zoxide"
    "atuin"
    "eza"
    "bat"
    "delta"
    "btop"
    "tealdeer"
    "tree"
    "lsof"
    "inetutils"
    "rsync"
    "pv"
    "curl"
    "wget"
    "jq"
    "unzip"
    "zip"
    "file"
    "p7zip"
    "gnugrep"
    "gawk"
    "gnumake"
    "always-on"
    "openssh"
    "hermes-agent"
    "pi-coding-agent"
  ];

  linuxModules = [
    "locale"
    "bootloader"
    "sops"
    "nftables"
    "journald"
    "polkit"
    "net-tools"
    "traceroute"
    "psmisc"
    "pciutils"
    "usbutils"
    "iproute2"
    "knockd"
    "lan"
    "syncthing"
    "wireguard"
    "wireguard-watchdog"
  ];

  darwinModules = [
    "homebrew"
    "system"
    "wireguard-app"
  ];

  allowedUnfree = [ "claude-code" ];
}
