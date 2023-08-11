{
  inputs.nixpkgs.url = "git+file:nixpkgs"; # "github:NixOS/nixpkgs/nixos-unstable-small"; # nixos-unstable #git+file:nixpkgs;
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.impermanence.url = "github:nix-community/impermanence/6138eb8e737bffabd4c8fc78ae015d4fd6a7e2fd";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  outputs = { self, nixpkgs, rust-overlay, ... }@attrs: rec {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix ];
    };

    nixosConfigurations.rpi4 = nixpkgs.lib.nixosSystem {
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel.nix"
        {
          nixpkgs.system = "aarch64-linux";
          boot.supportedFilesystems = nixpkgs.lib.mkForce [ "btrfs" "vfat" ];
          sdImage.compressImage = false;
          system.stateVersion = "23.11";
        }
      ];
    };
    images.rpi4 = nixosConfigurations.rpi4.config.system.build.sdImage;
  };
}
