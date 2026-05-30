# Context

Two parallel goals:
1. **Test before deploy** — copy `.nixoshybrid` to a new `.nixostest` repo, apply the mama visibility security changes there, validate they evaluate cleanly, then port back to the real repo.
2. **One-command deploys** — add `deploy-rs` to `.nixoshybrid` so all machines can be built and activated from a single `deploy .` rather than SSHing into each one individually.

# Plan

## Part A — Create `.nixostest` repo

### Step 1 — Create GitHub repo

Use `mcp__github__create_repository` to create `suazo-dev/.nixostest` (private). If the MCP scope blocks it, the user creates it manually at github.com, then we push.

### Step 2 — Copy `.nixoshybrid` locally and re-point remote

```bash
cp -r /home/user/.nixoshybrid /home/user/.nixostest
cd /home/user/.nixostest
git remote set-url origin git@github.com:suazo-dev/.nixostest.git
# remove the old branch tracking and set up fresh
git push -u origin main
```

Also update `repoDirName` in `lib/defaults.nix` from `.nixoshybrid` to `.nixostest` (so the `repoRoot` path in mkHost.nix points to the right place on disk).

### Step 3 — Apply the 4 security changes in `.nixostest`

**File: `network/registry.nix`** — Replace flat `sshAuthorizedKeysFor` with role-aware grants:

```nix
sshAuthorizedKeysFor = machineName:
  let
    machine = baseMachines.${machineName};
    canConnect = otherName:
      let other = baseMachines.${otherName};
      in if machine.nodeName == "gateway" then true
         else if machine.nodeName == "portal" then
           other.nodeName == "gateway" || other.nodeName == "portal"
         else  # core, storage
           other.nodeName == "gateway" || other.nodeName == "core" || other.nodeName == "storage";
    otherNames = builtins.filter (name: name != machineName) machineNames;
  in lib.unique (map (name: baseMachines.${name}.sshPublicKey)
       (builtins.filter (name:
         baseMachines.${name}.sshPublicKey != null && canConnect name
       ) otherNames));
```

Effect: portal machines (slim/tee) are removed from mama/papa's `authorized_keys`.

**File: `modules/nftables/nftables.nix`** — Fix `trustedUserIps` (limits mama's SSH input to core-network IPs only):

```nix
trustedUserIps =
  lib.unique (lib.concatMap (name:
    let machine = allMachines.${name};
    in if name != machineName && builtins.hasAttr "core" (machine.wg or {})
       then [ machine.wg.core.ip ]
       else []
  ) (builtins.attrNames allMachines));
```

**File: `modules/nftables/nftables.nix`** — Fix tiny's forward chain (same-network only):

```nix
# Replace:
#   iifname { ${hubInterfaceSet} } oifname { ${hubInterfaceSet} } accept
# With:
${lib.concatStringsSep "\n            " (map (iface:
  "iifname \"${iface}\" oifname \"${iface}\" accept"
) hubInterfaces)}
```

**File: `modules/zsh/` (find alias file)** — Portal-aware two-hop alias:

```zsh
if [[ "$ZSH_HOST_PORTAL" == "1" ]]; then
  alias sshmama="ssh -t suazo@tiny 'TERM=xterm-256color ssh -t suazo@mama \"LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 tmux -u new -As main\"'"
  alias sshpapa="ssh -t suazo@tiny 'TERM=xterm-256color ssh -t suazo@papa \"LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 tmux -u new -As main\"'"
else
  alias sshmama="TERM=xterm-256color ssh -t suazo@mama 'LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 tmux -u new -As main'"
  alias sshpapa="TERM=xterm-256color ssh -t suazo@papa 'LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 tmux -u new -As main'"
fi
```

### Step 4 — Validate in `.nixostest`

```bash
cd /home/user/.nixostest
nix flake check
# If check is slow, build specific machines:
nix build .#nixosConfigurations.mama.config.system.build.toplevel
nix build .#nixosConfigurations.tiny.config.system.build.toplevel
nix build .#nixosConfigurations.slim.config.system.build.toplevel
```

Fix any evaluation errors before proceeding.

### Step 5 — Commit and push `.nixostest`

---

## Part B — Add `deploy-rs` to `.nixoshybrid`

**File: `flake.nix`** — Add input and `deploy` output.

### Input addition

```nix
deploy-rs = {
  url = "github:serokell/deploy-rs";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### Output addition (inside `flake = let ... in { }`)

The existing let-block already has `machineSystem` and `linuxMachineNames`. Add:

```nix
# After existing nixosConfigurations / darwinConfigurations:
deploy.nodes = lib.genAttrs linuxMachineNames (machineName:
  let hostname = (import (./machines + "/${machineName}/default.nix")).hostName or machineName;
  in {
    inherit hostname;
    profiles.system = {
      sshUser = "suazo";
      user = "root";
      path = inputs.deploy-rs.lib.${machineSystem machineName}.activate.nixos
               self.nixosConfigurations.${machineName};
    };
  });

checks = builtins.mapAttrs
  (_: deployLib: deployLib.deployChecks self.deploy)
  inputs.deploy-rs.lib;
```

### SSH sudo requirement

`deploy-rs` SSHes as `suazo` and switches to root via sudo. Add to the base node config (or `nodes/base.nix` / a shared module):

```nix
security.sudo.extraRules = [{
  users = [ "suazo" ];
  commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
}];
```

Or, if the user already has passwordless sudo (likely given `wheel` membership), this may already be satisfied.

### Usage

```bash
# Deploy all linux machines in parallel:
deploy .

# Deploy a single machine:
deploy .#mama

# Build without deploying:
deploy . --dry-activate
```

Machines are reached by their `hostName` (which resolves via the existing `network/hosts.nix` `/etc/hosts` entries, or mDNS, or LAN DNS). The deploying machine must be able to reach them (i.e., must be on LAN or VPN).

---

## Deployment order (when porting changes back from `.nixostest` to `.nixoshybrid`)

1. `deploy .#mama .#papa` — lock down core machines first
2. `deploy .#tiny` — apply forward chain
3. `deploy .#slim .#tee` — new aliases land last

## Files modified

| File | Change |
|---|---|
| `.nixoshybrid/flake.nix` | deploy-rs input + deploy/checks outputs |
| `.nixoshybrid/lib/defaults.nix` | n/a (only `.nixostest` copy changes repoDirName) |
| `network/registry.nix` | role-based sshAuthorizedKeysFor |
| `modules/nftables/nftables.nix` | trustedUserIps + forward chain |
| `modules/zsh/<alias file>` | portal-aware sshmama/sshpapa aliases |
