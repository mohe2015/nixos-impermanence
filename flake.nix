{
  inputs.nixpkgs.url = "git+file:nixpkgs"; # "github:NixOS/nixpkgs/nixos-unstable"; # ; # "github:NixOS/nixpkgs/nixos-unstable-small"; # nixos-unstable #git+file:nixpkgs;
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.impermanence.url = "github:nix-community/impermanence/6138eb8e737bffabd4c8fc78ae015d4fd6a7e2fd";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # lib.attrsets.recursiveUpdate
  outputs = { self, nixpkgs, flake-utils, rust-overlay, nixos-hardware, ... }@attrs: nixpkgs.lib.updateManyAttrsByPath [
    {
      path = [ "nixosConfigurations" "nixos" ];
      update = old: nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [ ./configuration.nix ];
        };
    }
  ]
  (flake-utils.lib.eachDefaultSystem
    (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      rec {
        nixosConfigurations.rpi4-image = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
          ];
        };

        rpi4-image = nixosConfigurations.rpi4-image.config.system.build.isoImage;

        packages = {
          test = pkgs.vmTools.runInLinuxVM (pkgs.runCommand "test.img"
            { 
              preVM = ''
                touch $out
                ${pkgs.qemu_kvm}/bin/qemu-img create -f raw $out 8192M
              '';

              QEMU_OPTS = "-drive file=$out,format=raw,if=virtio,cache=unsafe,werror=report";
            }
            ''
              # https://nixos.org/manual/nixos/unstable/
              ${pkgs.parted}/bin/parted /dev/${pkgs.vmTools.hd} -- mklabel gpt
              ${pkgs.parted}/bin/parted /dev/${pkgs.vmTools.hd} -- mkpart ESP fat32 1MB 512MB
              ${pkgs.parted}/bin/parted /dev/${pkgs.vmTools.hd} -- set 1 esp on
              ${pkgs.parted}/bin/parted /dev/${pkgs.vmTools.hd} -- mkpart root btrfs 512MB 100%
              ${pkgs.btrfs-progs}/bin/mkfs.btrfs --label NIXOS_SD --uuid 44444444-4444-4444-8888-888888888888 --checksum xxhash --data single --metadata dup /dev/${pkgs.vmTools.hd}2
              ${pkgs.dosfstools}/bin/mkfs.fat -F 32 -n boot /dev/sda1
              ${pkgs.util-linux}/bin/mount /dev/disk/by-label/nixos /mnt
              ${pkgs.coreutils}/bin/mkdir -p /mnt/boot
              ${pkgs.util-linux}/bin/mount /dev/disk/by-label/boot /mnt/boot
              ${pkgs.nixos-generate-config}/bin/nixos-generate-config --root /mnt

            '');
        };
      }
    ));
}
