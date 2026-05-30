default := "thekorn-dev"
host    := "thekorn@thekorn-dev"

# Build the system closure on the VM (no activation).
build target=default:
    nix run nixpkgs#nixos-rebuild -- build \
        --flake .#{{target}} \
        --build-host {{host}}

# Dry-activate: build + show what would change, don't switch.
dry target=default:
    nix run nixpkgs#nixos-rebuild -- dry-activate \
        --flake .#{{target}} \
        --target-host {{host}} \
        --build-host {{host}} \
        --sudo

# Build & switch on the VM. Activates immediately.
deploy target=default:
    nix run nixpkgs#nixos-rebuild -- switch \
        --flake .#{{target}} \
        --target-host {{host}} \
        --build-host {{host}} \
        --sudo

# Build, set as next boot generation, but don't activate now.
boot target=default:
    nix run nixpkgs#nixos-rebuild -- boot \
        --flake .#{{target}} \
        --target-host {{host}} \
        --build-host {{host}} \
        --sudo

# Update flake inputs (nixpkgs etc.).
update:
    nix flake update

# Show current generation list on the VM.
generations:
    ssh {{host}} 'sudo nix-env --list-generations --profile /nix/var/nix/profiles/system'

# Roll back to previous generation.
rollback:
    ssh {{host}} 'sudo nixos-rebuild switch --rollback'
