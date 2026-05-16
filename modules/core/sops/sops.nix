{ inputs, spec, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../../secrets + "/${spec.secretFileName}.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = false;
  };
}
