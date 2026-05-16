{
  pkgs,
  spec,
  ...
}: {
  environment.systemPackages = with pkgs; [helix evil-helix];

  home-manager.users.${spec.user} = {...}: {
  };
}
