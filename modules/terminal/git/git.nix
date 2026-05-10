{ pkgs, spec, ... }:
{
  home-manager.users.${spec.user} = { ... }: {
    programs.git = {
      enable = true;
      package = pkgs.git;
      settings = {
        user.name = "suazo-dev";
        user.email = "me@suazo.dev";
        init.defaultBranch = "main";
        pull.rebase = false;
      };
    };
  };
}
