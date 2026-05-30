{
  description = "thekorn-dev: NixOS Parallels VM managed from macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    {
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
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShells.default = pkgs.mkShell {
        packages = [pkgs.just];
      };
    });
}
