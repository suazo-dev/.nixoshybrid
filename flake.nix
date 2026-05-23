{
  description = "Suazo custom modular NixOS framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      flake = let
        lib = nixpkgs.lib;
        entries = builtins.readDir ./machines;
        machineNames =
          builtins.filter
          (n: entries.${n} == "directory" && builtins.pathExists (./machines + "/${n}/default.nix"))
          (builtins.attrNames entries);
        machineSystem = machineName:
          let
            rawMachine = import (./machines + "/${machineName}/default.nix");
          in
            rawMachine.system or "x86_64-linux";
        linuxMachineNames = builtins.filter (n: lib.hasSuffix "-linux" (machineSystem n)) machineNames;
        darwinMachineNames = builtins.filter (n: lib.hasSuffix "-darwin" (machineSystem n)) machineNames;
        mkHost = import ./lib/mkHost.nix {inherit inputs lib;};
      in {
        nixosConfigurations = lib.genAttrs linuxMachineNames mkHost;
        darwinConfigurations = lib.genAttrs darwinMachineNames mkHost;
      };
    };
}
