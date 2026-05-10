 { ... }:
# let
#   useIwd = spec.facts.network.useIwd or false;
#   useNM = spec.facts.network.useNetworkManager or false;
# in
 {
#   networking.wireless.iwd = lib.mkIf useIwd {
#     enable = true;
#     settings.DriverQuirks.UseDefaultInterface = true;
#   };
#
#   networking.networkmanager.wifi.backend = lib.mkIf (useIwd && useNM) "iwd";
 }
