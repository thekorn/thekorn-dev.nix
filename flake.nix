{
  description = "thekorn-dev: NixOS Parallels VM managed from macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.thekorn-dev = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./hosts/thekorn-dev
        ./modules/base.nix
        ./modules/users.nix
        ./modules/ssh.nix
        ./modules/parallels.nix
      ];
    };
  };
}
