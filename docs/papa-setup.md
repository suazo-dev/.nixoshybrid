# Papa Setup

`papa` is defined as an `aarch64-darwin` host in this repo.

## Bootstrap nix-darwin

1. Install official Nix on the Mac.

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

If `nix` is not in your shell yet, open a new Terminal or run:

```sh
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

2. Copy this local working tree to `~/.nixoshybrid` on `papa`.
   For example, from a machine that can SSH into the Mac:

```sh
rsync -a --delete ~/.nixoshybrid/ papa:~/.nixoshybrid/
```

   You can also use AirDrop, a USB drive, or any other local copy method.
3. Apply the Darwin config:

```sh
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.nixoshybrid#papa
```

After that, use:

```sh
darwin-rebuild switch --flake ~/.nixoshybrid#papa
```

## WireGuard

Secrets stay manual.

If you are reusing `mama`'s current `wg0` identity for the first cutover, import the existing
`mama` private key into the WireGuard app on `papa` and keep `10.0.0.2/24` as the tunnel
address. Do not leave `mama` using that same key at the same time.

Create the `papa -> tiny` tunnel yourself with these values:

- address: `10.0.0.2/24`
- peer allowed IPs: `0.0.0.0/0, ::/0`
- persistent keepalive: `25`
- endpoint: your chosen `tiny` `wg0` endpoint

This is a full-tunnel setup: `papa`'s outbound internet traffic should leave through `tiny`, not
directly through the local WAN.

The repo installs a helper on `papa` called `wireguard-papa-template` that prints the expected
tunnel skeleton with the right address and full-tunnel `AllowedIPs`.

If you are reusing the current core `wg0` identity from `mama`, you do not need to change the
trusted `wg0` public key on `tiny`.

If you generate a brand new `papa` keypair instead, then you need to replace the trusted `wg0`
peer key on `tiny` with `papa`'s public key.

## Screen Sharing

Turn on macOS `Screen Sharing` on `papa` if you want desktop access over WireGuard.

- connect to `papa` over its WireGuard IP
- use the built-in Screen Sharing app or a VNC client
- grant any macOS permissions it asks for

## macOS settings

Turn on these system settings:

- `Remote Login`
- `Wake for network access`
- prevent sleep while on power

If you want a fully headless setup, use a display dongle so remote resolution stays sane.

## Switch mama behind papa

When `papa` is online and reachable:

1. Add `network.papaIp` to `machines/mama/facts.nix`.
2. Set `storage.nfs.enable = true` in `machines/mama/facts.nix`.
3. Import `mama`'s current `wg0` private key into the WireGuard app on `papa`.
4. Bring `papa` up as `10.0.0.2` and leave `mama` off that direct tunnel.
5. Portals should target `papa`; only `papa` talks directly to `mama`.
6. `mama` should only accept SSH/NFS from `papa`'s LAN IP, not from `tiny` or the portals.

`papa` reaches `tiny` over `10.0.0.1`, and portals reach `papa` over `10.0.0.2`.

## Mount mama on papa

This repo installs two helper commands on `papa`:

```sh
mount-mama
umount-mama
```

They use the NFS path from `machines/papa/facts.nix` and `machines/mama/facts.nix`.
