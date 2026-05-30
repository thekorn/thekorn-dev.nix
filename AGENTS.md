# thekorn-dev.nix — NixOS VM config for Parallels

This is a **Nix flake**, not an application. No tests, no linting, no CI.
NixOS 25.11, aarch64-linux, deployed from the macOS host to a Parallels VM.

## Commands

`just` is provided by the flake's devShell (`nix develop`).

| Command | What it does |
|---------|-------------|
| `just deploy`      | Build on VM, switch, then `prlctl restart` |
| `just dry`         | Dry-activate (show changes, no switch) |
| `just boot`        | Build + stage for next boot only |
| `just rollback`    | SSH in, roll back generation |
| `just generations` | List system generations on the VM |
| `just update`      | `nix flake update` (bumps inputs) |
| `just start` / `stop` / `reboot` | Host-side `prlctl` VM lifecycle |
| `just snapshot`    | `prlctl snapshot` (timestamped) |

Lifecycle recipes (`start`, `stop`, `reboot`, `snapshot`) shell out to
`prlctl` on the mac, so they only work on the Parallels host.

## Build model

- Flake evaluated **locally** on macOS.
- Build + activation happen **on the VM** (`--build-host` + `--target-host`).
- No aarch64-linux builder needed on the mac.
- `--sudo` works because `security.sudo.wheelNeedsPassword = false`
  (set in `modules/users.nix`).

## Must-know constraints

- **`hosts/thekorn-dev/hardware-configuration.nix`** — auto-generated, do not edit.
- **`system.stateVersion`** — must stay at `"25.11"` (the initial install
  release), do not bump.
- **Unfree packages** — `nixpkgs.config.allowUnfree = true` is set in
  `modules/base.nix`, but `modules/parallels.nix` narrows it with an
  `allowUnfreePredicate` that only permits `prl-tools`. Keep that scope.
- **Flakes + `nix-command`** — enabled for the Nix daemon in
  `modules/base.nix` (required to eval the flake on the VM).
- **`just update`** bumps `nixpkgs`. If the nixos branch moves to a new
  release, do **not** also bump `system.stateVersion` without reading
  the release notes first.
- **`codebook.toml`** holds the project spell-check wordlist; add new
  domain terms here if a spell-checker flags them.

## Re-bootstrapping (fresh VM)

First deploy must run **on the VM itself** (no passwordless sudo yet):

```sh
rsync -az --delete --exclude=.git ./ thekorn@thekorn-dev:/home/thekorn/thekorn-dev.nix/
ssh -t thekorn@thekorn-dev 'cd ~/thekorn-dev.nix && sudo nixos-rebuild switch --flake .#thekorn-dev'
```

After that, `just deploy` from the mac works end-to-end.

## Layout

```
flake.nix                       — nixosConfigurations.thekorn-dev + devShell (just)
hosts/thekorn-dev/default.nix   — hostname, bootloader, stateVersion
hosts/thekorn-dev/hardware-configuration.nix — generated, do not edit
modules/base.nix                — nix daemon (flakes, gc, optimise),
                                  locale (Europe/Berlin, de_DE), packages
modules/users.nix               — thekorn user, authorized SSH key,
                                  passwordless sudo for wheel
modules/ssh.nix                 — OpenSSH, key-only (root login permitted)
modules/parallels.nix           — Parallels guest tools, unfree predicate
justfile                        — deploy / build / rollback / VM lifecycle
codebook.toml                   — spell-check wordlist
```
