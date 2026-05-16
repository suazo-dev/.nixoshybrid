# nixoshybrid

Modular NixOS/nix-darwin framework. One base module pool, node types define deviations, machines declare identity. Everything else is computed.

---

## Architecture

```
machines/        The ONLY source of truth. Each machine declares what it is.
modules/         Flat pool of all modules. Referenced by name.
nodes/base.nix   Single list of every module. Add once, everything gets it.
nodes/<type>.nix  Node types. Only say what to REMOVE from base + network shape.
network/         Registry (computed from machines) + hosts resolution.
lib/             Build system (mkHost, schema, resolver).
secrets/         Encrypted sops files. Named <nodeName>-<instanceName>.yaml.
```

---

## How it works

1. Machine declares: hostname, node type, instance, platform, keys, LAN config
2. System looks up the node type → applies base modules minus that node's removes
3. Platform filters: linux gets `linuxModules`, darwin gets `darwinModules`
4. Registry scans all machines → computes WireGuard IPs, peers, hosts, secrets paths
5. Build outputs a complete NixOS or nix-darwin system

---

## Operations

### Add a module (for all machines)

1. Create `modules/<name>/<name>.nix` with the module config
2. Add `"<name>"` to `nodes/base.nix` under the appropriate list:
   - `modules` → cross-platform
   - `linuxModules` → linux only
   - `darwinModules` → darwin only
3. Rebuild all machines

### Remove a module (from all machines)

1. Remove it from `nodes/base.nix`
2. Optionally delete `modules/<name>/`
3. Rebuild

### Remove a module from one node type only

1. Add it to `remove` (cross-platform), `removeLinux`, or `removeDarwin` in `nodes/<type>.nix`
2. Rebuild machines of that type

---

### Add a new machine (new instance of an existing node type)

1. Create the directory:
   ```
   mkdir machines/<name>
   ```

2. Create `machines/<name>/default.nix`:
   ```nix
   {
     hostName = "<name>";
     nodeName = "<gateway|storage|portal|core>";
     instanceName = "<alpha|bravo|charlie|delta|echo>";
     user = "suazo";
     system = "x86_64-linux";  # or "aarch64-darwin"
     stateVersion = "25.11";
     homeStateVersion = "25.11";
     hardware = "hardware-configuration.nix";

     wgPublicKeys = {
       # one entry per network the node type participates in
       # check nodes/<type>.nix → network.wg for which networks
     };

     sshPublicKey = "ssh-ed25519 ...";

     # only if this machine has a static LAN IP
     lan = {
       interface = "eno1";
       ip = "192.168.8.XX";
       wakeMac = "XX:XX:XX:XX:XX:XX";
     };

     extraModules = [ ];
     allowedUnfree = [ ];
     mutableUsers = true;
   }
   ```

3. Generate WireGuard keypairs (one per network the node type joins):
   ```bash
   wg genkey | tee private.key | wg pubkey > public.key
   ```
   Put public keys in `wgPublicKeys`. Keep private keys for the secrets file.

4. Copy hardware config from the machine:
   ```bash
   cp /etc/nixos/hardware-configuration.nix machines/<name>/hardware-configuration.nix
   ```

5. Create the sops secrets file `secrets/<nodeName>-<instanceName>.yaml`:
   ```bash
   sops secrets/<nodeName>-<instanceName>.yaml
   ```
   Add WireGuard private keys under the paths the wireguard module expects:
   ```yaml
   wireguard/<nodeName>-<instanceName>-<networkName>: <private-key>
   ```

6. Ensure the machine has its age key at `/var/lib/sops-nix/key.txt`

7. Rebuild:
   ```bash
   sudo nixos-rebuild switch --flake "$HOME/.nixoshybrid#<name>"
   ```
   Also rebuild other machines so their peer lists update.

---

### Remove a machine

1. Delete `machines/<name>/`
2. Optionally delete `secrets/<nodeName>-<instanceName>.yaml`
3. Rebuild remaining machines so their WireGuard peer lists and hosts entries update

---

### Swap a machine (replace broken hardware with same role)

This is a clone — same node type, same instance name, same network identity.

1. On the replacement machine, create `machines/<name>/default.nix` with:
   - Same `nodeName` and `instanceName` as the broken machine
   - Same `wgPublicKeys` and `sshPublicKey` (same keys = same identity)
   - Same `lan.ip` if applicable
   - New `hostName` if you want, or keep the old name

2. Copy the broken machine's sops secrets file — or keep the same filename since it's the same `<nodeName>-<instanceName>`

3. Put the age key and WireGuard private keys on the new hardware

4. Copy/generate `hardware-configuration.nix` for the new hardware

5. Rebuild. The network doesn't know anything changed — same IPs, same keys, same peers.

---

### Temporarily reassign a role

Example: tiny (gateway) breaks, use slim (portal) as gateway temporarily.

1. Edit `machines/slim/default.nix`:
   - Change `nodeName` from `"portal"` to `"gateway"`
   - Change `instanceName` to match (e.g. `"alpha"`)
   - Copy `wgPublicKeys` and `lan` from tiny's file (same keys = same network identity)

2. Rebuild slim — it's now the gateway with all gateway config applied

3. Rebuild other machines so they update peer lists/hosts

4. When new hardware arrives, reverse the change:
   - Set slim back to `nodeName = "portal"`, `instanceName = "alpha"`, original keys
   - Set up the new gateway machine
   - Rebuild everything

---

### Add a new node type

1. Create `nodes/<type>.nix`:
   ```nix
   {
     supportedSystems = [ "linux" ];  # or [ "linux" "darwin" ]

     remove = [
       # modules from base.nix this type does NOT need
     ];

     removeLinux = [ ];
     # removeDarwin = [ ];  # if needed

     network = {
       wg = {
         # which WireGuard networks this type joins
         # octet = base IP assignment (instance offset added automatically)
         <networkName> = { octet = <number>; };
         # add listen = true; if this node should listen (e.g. p2p server)
       };
     };

     facts = {
       # node-specific defaults that override defaultFacts.nix
     };
   }
   ```

2. Make sure chosen octets don't collide with existing nodes on the same network

3. Create a machine that uses this node type

---

### Add a new WireGuard network

1. Add to `networks` in `network/registry.nix`:
   ```nix
   <name> = {
     subnet = "10.X.0.0/24";
     port = 518XX;          # unique port
     hostPriority = X;      # higher = preferred for host resolution
     fullTunnel = false;    # true = route all traffic through gateway
     extraAllowedIPs = [ ]; # other subnets reachable through this network
     # type = "p2p";        # add this for direct peer-to-peer (no gateway hub)
   };
   ```

2. Add the network to relevant node types in `nodes/<type>.nix` under `network.wg`

3. Generate keypairs for each machine on this network

4. Add public keys to each machine's `wgPublicKeys`

5. Add private keys to each machine's sops secrets file

6. Rebuild all affected machines

---

### Rebuild commands

Linux:
```bash
sudo nixos-rebuild switch --flake "$HOME/.nixoshybrid#<hostname>"
```

Darwin:
```bash
sudo darwin-rebuild switch --flake "$HOME/.nixoshybrid#<hostname>"
```

---

## Key rules

- **Never edit registry computation logic** — only touch the data blocks at the top (`networks`, `endpoint`, `lan`, `instanceOrdinals`)
- **Machine file is the only source of truth** — all identity data (keys, IPs, node assignment) lives there
- **Nodes only subtract** — they say what to remove from base, never duplicate module lists
- **One place to add** — new module goes in `base.nix` once, every machine gets it
- **Secrets follow the role** — named `<nodeName>-<instanceName>.yaml`, not by hostname
