{
  inputs.nixpkgs.url = "git+file:nixpkgs"; # "github:NixOS/nixpkgs/nixos-unstable"; # ; # "github:NixOS/nixpkgs/nixos-unstable-small"; # nixos-unstable #git+file:nixpkgs;
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.impermanence.url = "git+file:impermanence";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nix.url = "github:NixOS/nix";

  # lib.attrsets.recursiveUpdate
  outputs = { self, nixpkgs, flake-utils, rust-overlay, nixos-hardware, nix, ... }@attrs: nixpkgs.lib.updateManyAttrsByPath [
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
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pkgsAarch64 = nixpkgs.legacyPackages.aarch64-linux;
        in
        rec {
          nixosConfigurations.rpi4-image = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
            ];
          };

          rpi4-image = nixosConfigurations.rpi4-image.config.system.build.isoImage;

          nixosConfigurations.minimal-image = let pkgs = pkgsAarch64; in nixpkgs.lib.nixosSystem {
            system = "x86_64-linux"; # TODO FIXME
            modules = [
              {
                networking.hostName = "rpi4";

                boot.loader.systemd-boot.enable = true;

                boot.loader.efi.efiSysMountPoint = "/build";

                boot.kernelPackages = pkgs.linuxPackages_latest;

                nix.settings.experimental-features = [ "nix-command" "flakes" ];

                fileSystems."/" =
                  {
                    device = "/dev/disk/by-label/NIXOS_SD";
                    fsType = "btrfs";
                  };

                users.users = {
                  moritz = {
                    isNormalUser = true;
                    createHome = true;
                    description = "Moritz Hedtke";
                    extraGroups = [
                      "wheel"
                    ];
                    group = "users";
                    shell = pkgs.bashInteractive;
                    uid = 1001;
                    # mkpasswd --method=sha-512 --rounds=1000000
                    hashedPassword = "$6$rounds=1000000$1wy2XebNs.9OdhIf$75j2wShkEclpiStXf8JXSMgwYyACvQS3hoZLojH6BnXFaFQl/nElxKTKoFN7IEZdAPzuFXNqbMdX2DMChwAn60";
                  };
                };

                services.xserver = {
                  enable = true;
                  displayManager.sddm.enable = true;
                  desktopManager.plasma5.enable = true;
                };

                documentation.enable = false;

                system.stateVersion = "23.11";
              }
            ];
          };

          packages = rec {
            image-no-vm = pkgs.runCommand "test.img"
              { } ''
              #${pkgs.util-linux}/bin/fallocate -l 100MiB ./test.img
              #${pkgs.parted}/bin/parted ./test.img -- mklabel gpt
              #${pkgs.parted}/bin/parted ./test.img -- mkpart root btrfs 1MiB 100%
              #${pkgs.btrfs-progs}/bin/mkfs.btrfs --label NIXOS_SD --uuid 44444444-4444-4444-8888-888888888888 --checksum xxhash --data single --metadata dup ./test.img

              echo "ID=nixos" > /build/os-release
              mkdir -p /build/nix/var/nix/profiles/
              #touch /build/nix/var/nix/profiles/system.lock
              ln -s ${nixosConfigurations.minimal-image.config.system.build.toplevel} /build/nix/var/nix/profiles/system
              ln -s ${nixosConfigurations.minimal-image.config.system.build.toplevel} /build/nix/var/nix/profiles/system-1-link
              XDG_STATE_HOME=/build/nix/var NIX_PREFIX=/build/nix NIX_STORE_DIR=/build/nix/store NIX_DATA_DIR=/build/nix/share NIX_LOG_DIR=/build/nix/var/log/nix NIX_STATE_DIR=/build/nix/var/nix NIX_CONF_DIR=/build/nix/etc/nix NO_ROOT=1 KERNEL_INSTALL_CONF_ROOT=/build SYSTEMD_OS_RELEASE=/build/os-release SYSTEMD_RELAX_ESP_CHECKS=1 SYSTEMD_ESP_PATH=/build NIXOS_INSTALL_BOOTLOADER=1 ${nixosConfigurations.minimal-image.config.system.build.installBootLoader} ${nixosConfigurations.minimal-image.config.system.build.toplevel}
              mkdir /build/boot
              shopt -s extglob
              mv /build/!(boot|nix) /build/boot/

              ${pkgs.coreutils}/bin/truncate -s 10GiB $out
              ${pkgs.parted}/bin/parted $out -- mklabel gpt
              ${pkgs.parted}/bin/parted $out -- mkpart ESP fat32 1MiB 100MiB
              ${pkgs.parted}/bin/parted $out -- set 1 esp on
              ${pkgs.parted}/bin/parted $out -- mkpart root btrfs 100MiB 100%
              ${pkgs.parted}/bin/parted $out -- unit MiB print

              ${pkgs.util-linux}/bin/partx $out --nr 1 --pairs
              eval $(${pkgs.util-linux}/bin/partx $out --nr 1 --pairs)
              ${pkgs.util-linux}/bin/fallocate -l $(($SECTORS * 512)) ./esp.img
              ${pkgs.dosfstools}/bin/mkfs.fat -F 32 -n BOOT ./esp.img
              # TODO FIXME EFI does not seem to be copied
              ${pkgs.mtools}/bin/mcopy -s -i ./esp.img /build/boot/* ::
              dd conv=notrunc if=./esp.img of=$out seek=$START count=$SECTORS

              mkdir -p ./rootImage/nix/store
              mkdir -p ./rootImage/boot
              xargs -I % cp -a --reflink=auto % -t ./rootImage/nix/store/ < ${pkgs.closureInfo { rootPaths = nixosConfigurations.minimal-image.config.system.build.toplevel; }}/store-paths

              ${pkgs.util-linux}/bin/partx $out --nr 2 --pairs
              eval $(${pkgs.util-linux}/bin/partx $out --nr 2 --pairs)
              ${pkgs.util-linux}/bin/fallocate -l $(($SECTORS * 512)) ./root.img
              # Don't use this - this doesn't support compression and not deduplication which is really bad
              ${pkgs.btrfs-progs}/bin/mkfs.btrfs --rootdir ./rootImage --shrink --label NIXOS_SD --uuid 44444444-4444-4444-8888-888888888888 --checksum xxhash --data single --metadata dup ./root.img
              # did btrfs silently resize because of --rootdir?
              FILESIZE=$(stat -c%s ./root.img)
              if [ "$FILESIZE" > $(($SECTORS * 512)) ]; then
                echo "The btrfs filesystem is too small! $(($SECTORS * 512)) < $FILESIZE" 1>&2
                exit 1
              fi
  
              dd conv=notrunc if=./root.img of=$out seek=$START count=$SECTORS  
            '';

            verify-image-no-vm = pkgs.vmTools.runInLinuxVM (pkgs.runCommand "test.img"
              { }
              ''
                ${pkgs.kmod}/bin/modprobe loop
                ${pkgs.util-linux}/bin/losetup --partscan /dev/loop0 ${image-no-vm}
                ${pkgs.parted}/bin/parted /dev/loop0 -- unit MiB print
                ${pkgs.dosfstools}/bin/fsck.vfat -n -v -V /dev/loop0p1
                ${pkgs.btrfs-progs}/bin/btrfs check --readonly --check-data-csum /dev/loop0p2
                ${pkgs.coreutils}/bin/mkdir -p /mnt
                ${pkgs.util-linux}/bin/mount -t btrfs /dev/loop0p2 /mnt
                ${pkgs.coreutils}/bin/mkdir -p /mnt/boot
                ${pkgs.util-linux}/bin/mount -t vfat /dev/loop0p1 /mnt/boot
                ls -laR /mnt/boot/
                ln -s ${image-no-vm} $out
              '');
            # https://github.com/NixOS/nixpkgs/blob/71bf61d89b23ce33bd1334ca670ac20ff21008bb/nixos/lib/make-single-disk-zfs-image.nix#L113
            # TODO FIXME https://github.com/NixOS/nixpkgs/blob/71bf61d89b23ce33bd1334ca670ac20ff21008bb/nixos/lib/make-disk-image.nix#L16
            test = pkgs.vmTools.runInLinuxVM (pkgs.runCommand "test.img"
              {
                nativeBuildInputs = [
                  pkgs.nix
                ];

                memSize = "4G"; # increase when store size grows

                preVM = ''
                  touch $out
                  ${pkgs.qemu_kvm}/bin/qemu-img create -f raw $out 5G
                '';

                QEMU_OPTS = "-drive file=$out,format=raw,if=virtio,cache=unsafe,werror=report";
              }
              ''
                # https://nixos.org/manual/nixos/unstable/
                ${pkgs.parted}/bin/parted /dev/${pkgs.vmTools.hd} -- mklabel gpt
                ${pkgs.parted}/bin/parted /dev/${pkgs.vmTools.hd} -- mkpart ESP fat32 1MB 512MB
                ${pkgs.parted}/bin/parted /dev/${pkgs.vmTools.hd} -- set 1 esp on
                ${pkgs.parted}/bin/parted /dev/${pkgs.vmTools.hd} -- mkpart root btrfs 512MB 100%
                ${pkgs.dosfstools}/bin/mkfs.fat -F 32 -n boot /dev/${pkgs.vmTools.hd}1
                ${pkgs.coreutils}/bin/mknod /dev/btrfs-control c 10 234
                ${pkgs.btrfs-progs}/bin/mkfs.btrfs --label NIXOS_SD --uuid 44444444-4444-4444-8888-888888888888 --checksum xxhash --data single --metadata dup /dev/${pkgs.vmTools.hd}2
                ${pkgs.coreutils}/bin/mkdir -p /mnt/boot
                ${pkgs.util-linux}/bin/mount -t vfat /dev/${pkgs.vmTools.hd}1 /mnt/boot
                ${pkgs.kmod}/bin/modprobe btrfs
                ${pkgs.util-linux}/bin/mount -t btrfs -o compress-force=zstd /dev/${pkgs.vmTools.hd}2 /mnt

                nix-store < ${pkgs.closureInfo { rootPaths = [ nixosConfigurations.minimal-image.config.system.build.toplevel ]; }}/registration \
                  --load-db \
                  --option build-users-group ""

                mkdir -p /mnt/
                ${nixosConfigurations.minimal-image.config.system.build.nixos-install}/bin/nixos-install --option build-users-group "" --substituters "" --no-root-passwd --root /mnt --system ${nixosConfigurations.minimal-image.config.system.build.toplevel}
              '');
          };
        }
      ));
}
