# thekorn-dev.nix

Flake-managed NixOS configuration for the `thekorn-dev` Parallels VM,
deployed from the macOS host. NixOS 25.11, aarch64-linux.

## Layout

```
flake.nix                            # nixosConfigurations.thekorn-dev + devShell
hosts/thekorn-dev/
  default.nix                        # hostname, bootloader, stateVersion
  hardware-configuration.nix         # generated, do not edit
modules/
  base.nix                           # nix daemon, gc, locale, base packages
  users.nix                          # thekorn user, SSH key, NOPASSWD sudo
  ssh.nix                            # OpenSSH (key-only auth)
  parallels.nix                      # Parallels guest tools (prl-tools)
justfile                             # deploy / build / rollback / VM lifecycle
codebook.toml                        # spell-check wordlist
```

## Prerequisites (host)

- Nix with flakes enabled (Determinate Nix is fine).
- SSH config entry for `thekorn-dev` resolving to the VM, with key auth.
- Parallels Desktop, for the `prlctl`-based VM lifecycle recipes.

Enter the devShell (`nix develop`) to get `just` on `PATH`.

## Usage

From this directory on the mac:

```sh
just dry          # show what would change
just deploy       # build on VM, switch, then reboot
just boot         # build + stage for next boot
just rollback     # revert to previous generation
just generations  # list system generations on the VM
just update       # bump nixpkgs (and other flake inputs)

just start        # prlctl start
just stop         # prlctl stop
just reboot       # prlctl restart
just snapshot     # prlctl snapshot (timestamped)
```

`just deploy` automatically runs `just reboot` after switching.

## How it works

- `nixos-rebuild` runs on the mac, evaluates the flake locally, then
  invokes the Nix daemon on the VM (`--build-host`) to build the
  aarch64-linux closure. No local Linux builder is needed.
- The same VM is also `--target-host`, so activation happens in place.
- `--sudo` lets `thekorn` activate via passwordless sudo, granted by
  `security.sudo.wheelNeedsPassword = false` in
  [modules/users.nix](modules/users.nix).
- `modules/parallels.nix` enables guest tools and narrows the unfree
  allowance (set globally in `modules/base.nix`) to just `prl-tools`.
- The Nix daemon on the VM has `nix-command` and `flakes` enabled and
  trusts the `thekorn` user (see [modules/base.nix](modules/base.nix)).

## Re-bootstrapping from scratch

If the VM is ever reinstalled and the SSH key still works, the first
switch has to happen on the VM itself (the fresh system doesn't yet
have NOPASSWD sudo or `thekorn` as a trusted Nix user):

```sh
rsync -az --delete --exclude=.git ./ thekorn@thekorn-dev:/home/thekorn/thekorn-dev.nix/
ssh -t thekorn@thekorn-dev 'cd ~/thekorn-dev.nix && sudo nixos-rebuild switch --flake .#thekorn-dev'
```

After that one activation, `just deploy` from the mac works
end-to-end.
