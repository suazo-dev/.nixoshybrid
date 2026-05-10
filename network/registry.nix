# Single source of truth for all network identity.
#
# Machine names here are identifiers — like rows in a database.
# No module or facts.nix ever references another machine by name.
# They query the registry by role: "who is the gateway?",
# "who shares my WG network?", "who has the storage role?"
#
# To swap a device: change the entry name + keys. Nothing else breaks.
{
  gateway = {
    endpoint = "teenytiny.duckdns.org";
    duckdnsDomain = "teenytiny";
    machineName = "tiny";
  };

  networks = {
    core = {
      subnet = "10.0.0.0/24";
      port = 51820;
      fullTunnel = true;
      extraAllowedIPs = [ ];
    };

    portal = {
      subnet = "10.1.0.0/24";
      port = 51821;
      fullTunnel = false;
      extraAllowedIPs = [ "10.0.0.0/24" ];
    };

    # Point-to-point — not routed through gateway
    storage = {
      subnet = "10.2.0.0/24";
      port = 51822;
      type = "p2p";
      fullTunnel = false;
      extraAllowedIPs = [ ];
    };
  };

  lan = {
    subnet = "192.168.8.0/24";
  };

  # SSH public keys by role-based label.
  # Named by the role of the device that holds the private key.
  # Alpha/bravo disambiguate when multiple devices share a role.
  sshKeys = {
    portal-alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZmKT4DsStSgGCTBBHFk4B4YJ+NW2zXAZisaKF3MEpo";
    portal-bravo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIkwZUBkhznVjOcbgGAfQUKYOQJtNjxnTT3LDM2KMgcMB";
    gateway-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7RdfzUhnGivqsg+jlhyFb0V1yZY8YqZFmwpatZoDap";
    core-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKwZUBkhznVjOcbgGAfQUKYOQJtNjxnTT3LDM2KMgcMB";
  };

  machines = {
    tiny = {
      lan = {
        ip = "192.168.8.108";
        interface = "eno1";
        wakeMac = "00:23:24:73:05:91";
      };

      wg.core = {
        ip = "10.0.0.1";
        publicKey = "RyloTPHjCXGLn36WPczGPqnHJsjZrCjlog16AJyerGI=";
        secretName = "gateway-core";
      };

      wg.portal = {
        ip = "10.1.0.1";
        publicKey = "RyloTPHjCXGLn36WPczGPqnHJsjZrCjlog16AJyerGI=";
        secretName = "gateway-portal";
      };

      sshAuthorizedKeys = [ "portal-alpha" "core-key" ];
    };

    papa = {
      wg.core = {
        ip = "10.0.0.2";
        publicKey = "QWe9wAEzY7kZdXsF5cF4sRSToFlslXfiPNaS6TZZPE4=";
        secretName = "papa";
      };

      wg.storage = {
        ip = "10.2.0.1";
        publicKey = "tc096iNfSkkOSwkSNgpJve50Zn91o5cb/K4hsGmxB0s=";
        secretName = "core-storage";
      };

      sshAuthorizedKeys = [ "portal-bravo" "gateway-key" "portal-alpha" ];
    };

    tee = {
      wg.portal = {
        ip = "10.1.0.2";
        publicKey = "ZYVWprVyyBZ3twqlG0Oy4M4yFOd1k+rg2JvDZZgS6Bc=";
        secretName = "tee";
      };

      sshAuthorizedKeys = [ "gateway-key" "portal-alpha" ];
    };

    slim = {
      wg.portal = {
        ip = "10.1.0.3";
        publicKey = "IkovrxdCMGX0j5LmowsZYOE6Nxdm2kvRMBWWrpbu6FY=";
        secretName = "portal-alpha";
      };

      sshAuthorizedKeys = [ "portal-bravo" "gateway-key" ];
    };

    mama = {
      lan = {
        ip = "192.168.8.10";
        interface = "eno1";
        wakeMac = "c4:65:16:b6:8c:3c";
      };

      wg.storage = {
        ip = "10.2.0.2";
        publicKey = "AxqH2DCTlerWkJsTntUGlFA8OSnxR2Iv5FFyQux51TQ=";
        secretName = "storage-key";
        listenPort = 51822;
        endpoint = "192.168.8.10:51822";
      };

      sshAuthorizedKeys = [ "portal-bravo" "gateway-key" "portal-alpha" ];
    };
  };
}
