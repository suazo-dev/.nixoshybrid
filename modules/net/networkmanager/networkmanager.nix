{ lib, spec, ... }:
{
  networking.networkmanager.enable =
    lib.mkDefault (spec.facts.network.useNetworkManager or false);
}
