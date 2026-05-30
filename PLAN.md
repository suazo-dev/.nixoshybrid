# Full Audit — Issues Found

---

## CRITICAL — Security

### C1. `network/registry.nix:162` — SSH keys granted to all machines, no role filter
Every machine gets every other machine's SSH public key in its `authorized_keys`. Portal keys land in mama/papa. If a portal is stolen, the attacker's key works on core/storage machines directly.

**Fix:** Role-matrix filter. Portals may only key into gateway + other portals. Core/storage only accepts keys from gateway + core/storage.

### C2. `modules/nftables/nftables.nix:85-91` — storage firewall trusts portal IPs
`trustedUserIps` collects both core WireGuard IPs AND portal WireGuard IPs. The storage `input` chain then accepts SSH from all of them. Portals can directly SSH mama.

**Fix:** `trustedUserIps` on storage/core machines should only include gateway-role WireGuard IPs.

### C3. `modules/nftables/nftables.nix:138` — gateway forwards portal→core traffic
`iifname { wg-core, wg-portal } oifname { wg-core, wg-portal } accept` is a blanket hub-to-hub forward. Since both interfaces are in `hubInterfaces`, tiny happily routes packets from portals directly to mama/papa.

**Fix:** Same-interface-only forward: `iifname X oifname X accept` per interface. Cross-segment forward is dropped.

### C4. `modules/firewall/firewall.nix` — Darwin pf rule is inverted (CRITICAL)
The comment says "only user's laptops can initiate SSH/VNC into papa — tiny cannot." The implementation trusts `portalPeerIps` (slim, tee) to initiate into papa's SSH/VNC. This is the opposite of the intended model. A stolen portal has direct SSH access to papa at the macOS firewall level.

**Fix:** Trust `gatewayPeerIps` (tiny's core WireGuard IP) for inbound SSH/VNC initiation, not portal IPs. Portals reach papa by SSHing through tiny.

---

## ARCHITECTURE — Module system

### A1. `nodes/base.nix` — subtract-first, not add-per-role
Base declares 70+ modules. Nodes subtract what they don't need. Gateway's `remove` list has 40 entries. Every new module added to base silently lands on all machines until someone remembers to add it to every `remove` list. This is the wrong direction.

**Fix:** Shrink base to ~15 truly universal modules (nix, zsh, git, openssh, core CLI tools, always-on, sops, wireguard, nftables, locale, bootloader). Each node spec gets a `modules` list of what that role adds on top.

Example after fix:
```
nodes/gateway.nix  → modules = [ "duckdns" "knockd" "lan" ... ]
nodes/storage.nix  → modules = [ "nfs-server" "hermes-agent" "syncthing" ... ]
nodes/core.nix     → modules = [ "nvf" "zed" "lazygit" "devenv" "fonts" "firefox" ... ]
nodes/portal.nix   → modules = [ "networkmanager" "iwd" "fonts" "firefox" "wireguard-watchdog" ... ]
```

### A2. `lib/types/node.nix` — schema has no `modules` key
`allowedKeys` only lists `supportedSystems`, `remove`, `removeLinux`, `removeDarwin`, `network`, `facts`. Adding `modules` to a node spec would throw a validation error today.

**Fix:** Add `modules`, `linuxModules`, `darwinModules` to `allowedKeys`.

### A3. `lib/mkHost.nix` — only supports node-level removes, not adds
`moduleNames` is built from `baseModules ++ platformModules ++ extraModules`, filtered by node remove lists. There is no path for a node spec to contribute its own `modules` list.

**Fix:** After shrinking base, add: `nodeModules = nodeSpec.modules or []` and `nodeLinuxModules = nodeSpec.linuxModules or []` etc., then include them in the `moduleNames` union.

---

## CORRECTNESS — Module bugs

### M1. `modules/openssh/openssh.nix` — SSH client config uses wrong IP resolution
```nix
Host ${machine.hostName} ${machine.wg.core.ip or ""}
```
Portal machines have no `wg.core` — they're on `wg.portal`. The `or ""` fallback produces a blank IP, generating broken SSH config. Also generates entries for machines this machine can't reach.

There's also a conflict with `zsh.nix`, which generates its own `programs.ssh.matchBlocks` from `hosts.hostsFor`. Both modules set match blocks for the same hosts, potentially producing duplicate or conflicting home-manager SSH config.

**Fix:** Remove the SSH client config generation from `openssh.nix` entirely — `zsh.nix` already handles it correctly using `hosts.hostsFor`. `openssh.nix` should only configure the SSH server.

### M2. `modules/hermes-agent/hermes-agent.nix:27` — binary name embeds machine hostname
```nix
pkgs.writeShellScriptBin "hermes-${hermesHostName}" ...
```
Binary is named `hermes-mama`. If mama is replaced, the command changes. Every shell config, muscle memory, and script referencing it breaks.

**Fix:** Name it `hermes-remote` always (or `hermes-connect`).

### M3. `modules/hermes-agent/hermes-agent.nix:19` — hardcodes `wg.core` network name
```nix
hermesIp = hermesMachine.wg.core.ip;
```
If the storage machine ever participates on a differently-named network, this breaks. Should use `hosts.resolveIp machineName hermesHostName` which already handles routing logic correctly.

### M4. `modules/knockd/knockd.nix` — silent wrong-interface fallback
```nix
lanInterface = (registry.machines.${machineName}.lan or {}).interface or "eno1";
```
Falls back to `"eno1"` if the gateway machine has no `lan.interface` set. On a gateway with a different interface name, knockd silently listens on a non-existent interface with no error.

**Fix:** Remove the fallback. If `lan.interface` is missing on a gateway, throw explicitly.

### M5. `modules/duckdns/duckdns.nix` — guards with machine name instead of role
```nix
isGateway = machineName == registry.gateway.machineName;
```
Every other module uses `spec.nodeName == "gateway"`. This is inconsistent and would silently disable duckdns if the gateway machine is ever renamed.

**Fix:** `isGateway = spec.nodeName == "gateway"`.

### M6. `nodes/core.nix` — hardcoded username in NFS remote path fact
```nix
facts.storage.nfs.remotePath = "/home/suazo/Sync";
```
Node specs have no access to `spec.user`. This hardcodes the username. The `storage-mount.nix` module has a correct fallback (`"/home/${spec.user}/Sync"`), but this override takes priority.

**Fix:** Remove `remotePath` from `nodes/core.nix`. Let `storage-mount.nix` derive it from `spec.user`.

---

## POTENTIAL ISSUES — Worth verifying

### P1. `machines/tee/default.nix` — SSH key nearly identical to mama's
```
mama: ssh-ed25519 ... AAAAIKwZUBkhznVjOcbgGAfQUKYOQJtNjxnTT3LDM2KMgcMB
tee:  ssh-ed25519 ... AAAAIkwZUBkhznVjOcbgGAfQUKYOQJtNjxnTT3LDM2KMgcMB
```
Differ by one character (`IK` vs `Ik`). Technically different keys in base64, but suspiciously close. Could be a copy-paste error where tee was given the wrong key. If they're the same physical key pair, a stolen tee also owns mama's identity. Registry has no uniqueness check on `sshPublicKey`.

**Fix:** Verify tee's key is genuinely unique. Add a uniqueness assertion to `registry.nix`.

### P2. `machines/*/facts.nix` — username hardcoded in `sync.folder`
`papa/facts.nix`: `sync.folder = "/Users/suazo/Sync"`
`slim/facts.nix`: `sync.folder = "/home/suazo/Sync"`
`tee/facts.nix`:  `sync.folder = "/home/suazo/Sync"`

Machine facts files have no access to `spec.user`. This is an inherent tension — these files are pure Nix imported before the machine spec is assembled. For now the username is the same everywhere, but it's fragile. Not fixable without changing how facts are evaluated.

---

## DEPLOYMENT

### D1. `flake.nix` — no `deploy-rs`, every machine requires manual SSH
No deployment tooling. Rebuilding all machines means SSHing into each one individually. With deploy-rs added, `deploy .` from papa or tiny (never from portals) builds and activates all Linux machines in parallel.

**Add to `flake.nix`:**
- Input: `deploy-rs.url = "github:serokell/deploy-rs"`
- Output: `deploy.nodes` mapping each Linux machine using `machineSystem` and `linuxMachineNames` (already available in the flake let-block)
- Output: `checks` for deploy-rs validation
- Run from papa (core) or tiny (gateway) only — never from portals

---

# Execution Plan

## Phase 1 — Module architecture (A1, A2, A3)
Refactor `nodes/base.nix` down to universal-only. Add `modules`/`linuxModules`/`darwinModules` to node schema. Update `lib/mkHost.nix` to union node-contributed modules. Redistribute all removed modules into the appropriate node specs.

This is the foundation — do it first so security changes land on a clean module system.

## Phase 2 — Security fixes (C1, C2, C3, C4)
All four fixes are independent and can be applied together:
- `registry.nix`: role-matrix `sshAuthorizedKeysFor`
- `nftables.nix`: `trustedUserIps` gateway-only; per-segment forward chain
- `firewall.nix`: trust gateway, not portals, for inbound SSH/VNC to papa

## Phase 3 — Correctness fixes (M1–M6)
- `openssh.nix`: strip SSH client config generation, server-only
- `hermes-agent.nix`: stable binary name + `resolveIp` for IP lookup
- `knockd.nix`: hard error on missing interface
- `duckdns.nix`: `spec.nodeName` guard
- `nodes/core.nix`: remove hardcoded `remotePath`

## Phase 4 — Verification (P1, P2)
- Verify tee's SSH key is not a copy-paste of mama's; add uniqueness assertion to registry
- Note `sync.folder` username limitation; document it

## Phase 5 — deploy-rs (D1)
Add deploy-rs to `flake.nix`. Document that deploy runs from papa or tiny only.

## Phase 6 — Test in `.nixostest`
All changes applied to `.nixostest` first. Validate with:
```bash
nix flake check
nix build .#nixosConfigurations.{mama,tiny,slim}.config.system.build.toplevel
nix build .#darwinConfigurations.papa.system
```
Fix evaluation errors, commit, then port to `.nixoshybrid`.

## Phase 7 — Live deploy order
From papa or tiny:
```
deploy .#<gateway>    # tiny first — hardens the gate
deploy .#<storage>    # mama
deploy .#<portals>    # slim, tee — lose direct access last
```
papa self-applies: `darwin-rebuild switch --flake .#papa`

---

# Recovery
- All machines: static LAN IPs (`192.168.8.x`) reachable directly if WireGuard breaks
- Tiny: knockd port-knock `7000,8000,9000` opens emergency SSH for 60s
- Use `nixos-rebuild test` (not switch) to try config before committing
- deploy-rs auto-rolls back on activation failure
