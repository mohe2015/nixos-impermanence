{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # "git+file:nixpkgs"; # "github:NixOS/nixpkgs/nixos-unstable-small"; # nixos-unstable #git+file:nixpkgs;
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.impermanence.url = "github:nix-community/impermanence/6138eb8e737bffabd4c8fc78ae015d4fd6a7e2fd";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  outputs = { self, nixpkgs, rust-overlay, nixos-hardware, ... }@attrs: rec {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix ];
    };

    nixosConfigurations.rpi4-image = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
      ];
    };

    rpi4-image = nixosConfigurations.rpi4-image.config.system.build.isoImage;
  };
}
