# thekorn-dev.nix — NixOS VM config for Parallels

This is a **Nix flake**, not an application. No tests, linting, or CI.
NixOS 25.11, aarch64-linux, deployed from macOS to a Parallels VM.

## Commands

All operations via `just` (devShell provides it):

| Command | What it does |
|---------|-------------|
| `just deploy` | Build on VM, switch + reboot |
| `just dry`    | Dry-activate (show changes, no switch) |
| `just boot`   | Build + stage for next boot only |
| `just rollback` | SSH in, roll back generation |
| `just update` | `nix flake update` (bumps nixpkgs etc.) |

## Build model

- Flake evaluated **locally** on macOS.
- Build + activation happen **on the VM** (`--build-host` + `--target-host`).
- No aarch64-linux builder needed on the mac.
- `--sudo` works because `security.sudo.wheelNeedsPassword = false` (set in `modules/users.nix`).

## Must-know constraints

- **`hosts/thekorn-dev/hardware-configuration.nix`** — auto-generated, do not edit.
- **`system.stateVersion`** — must stay at `"25.11"` (the initial install release), do not bump.
- **Unfree packages** — only `prl-tools` is allowed, scoped in `modules/parallels.nix`.
- **`modules/base.nix`** — enables flakes + `nix-command` for the Nix daemon (required to eval).
- **`just update`** bumps the `nixpkgs` input; if the nixos branch changes, also update `system.stateVersion` (after reading the release notes).

## Re-bootstrapping (fresh VM)

First deploy must run **on the VM itself** (no passwordless sudo yet):

```sh
rsync -az --delete --exclude=.git ./ thekorn@thekorn-dev:/home/thekorn/thekorn-dev.nix/
ssh -t thekorn@thekorn-dev 'cd ~/thekorn-dev.nix && sudo nixos-rebuild switch --flake .#thekorn-dev'
```

After that, `just deploy` from the mac works.

## Workmux

`.workmux.yaml` configures workmux with `agent: amp` and
`worktree_dir: ~/.workmux/{project}`. All other settings are defaults.

## Layout

```
flake.nix                       — single nixosConfigurations.thekorn-dev
hosts/thekorn-dev/default.nix   — hostname, bootloader
modules/base.nix                — nix, locale, packages
modules/users.nix               — thekorn user, passwordless sudo
modules/ssh.nix                 — key-only SSH
modules/parallels.nix           — Parallels guest tools
justfile                        — deploy/build/rollback shortcuts
```
