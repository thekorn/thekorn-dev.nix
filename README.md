# thekorn-dev.nix

Flake-managed NixOS configuration for the `thekorn-dev` Parallels VM,
deployed from the macOS host.

## Layout

```
flake.nix                            # exposes nixosConfigurations.thekorn-dev
hosts/thekorn-dev/
  default.nix                        # host-specific (hostname, bootloader)
  hardware-configuration.nix         # generated, do not edit
modules/
  base.nix                           # nix, locale, timezone, packages
  users.nix                          # thekorn user + authorized SSH key
  ssh.nix                            # OpenSSH (key-only auth)
  parallels.nix                      # Parallels guest tools
justfile                             # deploy/build/rollback shortcuts
```

## Prerequisites (host)

- Nix with flakes enabled (Determinate Nix is fine).
- SSH config entry for `thekorn-dev` resolving to the VM, with key auth.
- `just` (`nix shell nixpkgs#just`) if you want the shortcuts.

## Usage

From this directory on the mac:

```sh
just dry        # show what would change
just deploy     # build on VM, switch
just boot       # build + stage for next boot
just rollback   # revert to previous generation
just update     # bump nixpkgs
```

The flake builds **on the VM itself** (`--build-host`), so no
aarch64-linux builder is required on the mac.

## First-time bootstrap

The current VM doesn't have passwordless sudo yet, so the very first
switch must happen on the VM directly:

```sh
rsync -az --delete --exclude=.git ./ thekorn@thekorn-dev:/home/thekorn/thekorn-dev.nix/
ssh -t thekorn@thekorn-dev 'cd ~/thekorn-dev.nix && sudo nixos-rebuild switch --flake .#thekorn-dev'
```

After that one activation, `security.sudo.wheelNeedsPassword = false` is
in effect and `just deploy` from the mac works end-to-end.
