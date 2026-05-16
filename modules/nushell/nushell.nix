{ pkgs, spec, ... }:
{
  environment.systemPackages = [ pkgs.nushell ];

  home-manager.users.${spec.user} = { config, ... }: {
    xdg.configFile."nushell".source =
      config.lib.file.mkOutOfStoreSymlink
      "${spec.repoRoot}/modules/terminal/nushell/dotfiles/nushell";
  };
}
