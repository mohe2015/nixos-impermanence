nix-build nixos -I nixos-config=nixos/modules/installer/sd-card/sd-image-aarch64.nix -A config.system.build.sdImage

# TODO create an image with uefi partition so qemu can boot it and we can run tests with it?
# or does it work with uboot?
https://u-boot.readthedocs.io/en/latest/board/emulation/qemu-arm.html
qemu-system-aarch64 -curses -machine virt -cpu cortex-a57 -bios u-boot.bin
https://github.com/u-boot/u-boot/blob/master/board/emulation/qemu-arm/Kconfig

qemu-system-aarch64 -machine help
raspi3b

# for rpi
eval "$(ssh-agent)"
ssh-add
ssh -A -v moritz@192.168.2.73
# Requesting authentication agent forwarding.


nix --extra-experimental-features nix-command --extra-experimental-features flakes shell nixpkgs#git
sudo chown moritz:users /etc/nixos/
git clone git@github.com:mohe2015/nixos-impermanence.git /etc/nixos
nix --extra-experimental-features nix-command --extra-experimental-features flakes flake update
sudo nixos-rebuild switch --flake /etc/nixos#rpi4
sudo btrfs filesystem resize max /
sudo compsize -x /
sudo reboot

sudo rm -fr /var/lib/sddm/.cache/sddm-greeter/qmlcache

cd ~/Documents/Godot/
git clone --depth 1 https://github.com/godotengine/godot.git

# you need to reexecute this to update the package definition
cd ~/Documents/Godot/godot/
nix develop /etc/nixos/nixpkgs#godot_4

source $stdenv/setup
set +e
phases="patchPhase ${preConfigurePhases[*]:-} configurePhase ${preBuildPhases[*]:-} buildPhase checkPhase ${preInstallPhases[*]:-} installPhase ${preFixupPhases[*]:-} fixupPhase installCheckPhase ${preDistPhases[*]:-} distPhase ${postPhases[*]:-}" genericBuild
./outputs/out/bin/godot4




mkpasswd --method=sha-512 --rounds=10000000













typeset -f genericBuild | grep 'phases='
https://nixos.wiki/wiki/Packaging/Tutorial
https://nixos.wiki/wiki/Nixpkgs/Create_and_debug_packages
phases="${prePhases[*]:-} unpackPhase" genericBuild
cd $sourceRoot
phases="patchPhase ${preConfigurePhases[*]:-}             configurePhase ${preBuildPhases[*]:-} buildPhase checkPhase             ${preInstallPhases[*]:-} installPhase ${preFixupPhases[*]:-} fixupPhase installCheckPhase             ${preDistPhases[*]:-} distPhase ${postPhases[*]:-}" genericBuild
#phases="${prePhases[*]:-} unpackPhase patchPhase ${preConfigurePhases[*]:-}             configurePhase ${preBuildPhases[*]:-} buildPhase checkPhase             ${preInstallPhases[*]:-} installPhase ${preFixupPhases[*]:-} fixupPhase installCheckPhase             ${preDistPhases[*]:-} distPhase ${postPhases[*]:-}" genericBuild
unpackPhase
cd $sourceRoot
patchPhase
configurePhase
buildPhase
installPhase








dbus-send --system --type=method_call --dest=org.bluez /org/bluez/hci0/dev_84_CF_BF_8E_61_6B org.bluez.Network1.Connect string:'nap'


nix run github:bennofs/nix-index#nix-index
nix run github:bennofs/nix-index#nix-locate -- bin/hello


https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/build-fhs-userenv-bubblewrap/default.nix
exportReferencesGraph/closureInfo
https://git.sr.ht/~fgaz/nix-bubblewrap/tree/master/item/nix-bwrap.tcl

https://github.com/containers/bubblewrap

bwrap --unshare-all --clearenv --new-session --die-with-parent --dev-bind / / /nix/store/6yv5wvi1xi2n034r046xdzqnkhsh90f9-home-manager-path/bin/Discord

https://github.com/valoq/bwscripts/blob/master/profiles/signal-desktop

https://wiki.archlinux.org/title/Bubblewrap
https://wiki.archlinux.org/title/Bubblewrap/Examples

https://wiki.archlinux.org/title/Bubblewrap/Examples

bwrap --unshare-all --clearenv --new-session --die-with-parent --ro-bind /nix/store /nix/store /nix/store/6yv5wvi1xi2n034r046xdzqnkhsh90f9-home-manager-path/bin/Discord

# minimal changes to upstream

bwrap \
    --ro-bind /nix/store /nix/store \
    --symlink usr/lib /lib \
    --symlink usr/lib64 /lib64 \
    --symlink usr/bin /bin \
    --symlink usr/bin /sbin \
    --ro-bind /usr/bin /usr/bin \
    --ro-bind /etc /etc \
    --dev /dev \
    --dev-bind /dev/dri /dev/dri \
    --proc /proc \
    --ro-bind /sys/dev/char /sys/dev/char \
    --ro-bind /sys/devices /sys/devices \
    --ro-bind /run/dbus /run/dbus \
    --dir "$XDG_RUNTIME_DIR" \
    --ro-bind "$XDG_RUNTIME_DIR/wayland-0" "$XDG_RUNTIME_DIR/wayland-0" \
    --ro-bind "$XDG_RUNTIME_DIR/pipewire-0" "$XDG_RUNTIME_DIR/pipewire-0" \
    --ro-bind "$XDG_RUNTIME_DIR/pulse" "$XDG_RUNTIME_DIR/pulse" \
    --tmpfs /tmp \
    --dir $HOME/.cache \
    --bind $HOME/.config/chromium $HOME/.config/chromium \
    --bind $HOME/Downloads $HOME/Downloads \
    --ro-bind /run/opengl-driver /run/opengl-driver \
    --ro-bind /run/user/$UID/bus /run/user/$UID/bus \
    --setenv FONTCONFIG_PATH /etc/fonts \
    /nix/store/9cm9481zw3zjd4jhp1d53cfbnliy4m8b-system-path/bin/strace -e 'trace=!clock_gettime,poll,write,futex,recvmsg,sendto,read,sendmsg,fallocate,ftruncate,gettimeofday,munmap,close,newfstatat,lseek,getpid,fcntl,dup,uname,madvise,mmap,socketpair,getpriority,gettid,mprotect,rt_sigprocmask,clone3,eventfd2,prlimit64,getegid,getuid,getgid,listen,getdents64,pread64,pwrite64,geteuid,pipe2,inotify_init' /nix/store/39d1qwkrdm00fvcp6l0znkq7kz8bvyrz-home-manager-path/bin/chromium --enable-features=UseOzonePlatform --ozone-platform=wayland

bwrap --dev-bind / / /nix/store/39d1qwkrdm00fvcp6l0znkq7kz8bvyrz-home-manager-path/bin/chromium --enable-features=UseOzonePlatform --ozone-platform=wayland

# modern chrome maybe with Ozone flag should work without setuid sandbox

bwrap --dev-bind / / /nix/store/6yv5wvi1xi2n034r046xdzqnkhsh90f9-home-manager-path/bin/Discord

# if we get "The SUID sandbox helper binary was found, but is not configured correctly. Rather than run without sandboxing I'm aborting now." then the user namespace failed so that error is kind of misleading.

bwrap --ro-bind /nix /nix /nix/store/6yv5wvi1xi2n034r046xdzqnkhsh90f9-home-manager-path/bin/Discord

bwrap --unshare-ipc --unshare-net --unshare-uts --unshare-cgroup --proc /proc --clearenv --new-session --die-with-parent --ro-bind /nix/store /nix/store /nix/store/9cm9481zw3zjd4jhp1d53cfbnliy4m8b-system-path/bin/strace /nix/store/6yv5wvi1xi2n034r046xdzqnkhsh90f9-home-manager-path/bin/Discord


bwrap \
    --ro-bind /nix/store /nix/store \
    --symlink usr/lib /lib \
    --symlink usr/lib64 /lib64 \
    --symlink usr/bin /bin \
    --symlink usr/bin /sbin \
    --ro-bind /usr/bin /usr/bin \
    --ro-bind /etc /etc \
    --dev /dev \
    --dev-bind /dev/dri /dev/dri \
    --proc /proc \
    --ro-bind /sys/dev/char /sys/dev/char \
    --ro-bind /sys/devices /sys/devices \
    --ro-bind /run/dbus /run/dbus \
    --dir "$XDG_RUNTIME_DIR" \
    --ro-bind "$XDG_RUNTIME_DIR/wayland-0" "$XDG_RUNTIME_DIR/wayland-0" \
    --ro-bind "$XDG_RUNTIME_DIR/pipewire-0" "$XDG_RUNTIME_DIR/pipewire-0" \
    --ro-bind "$XDG_RUNTIME_DIR/pulse" "$XDG_RUNTIME_DIR/pulse" \
    --tmpfs /tmp \
    --dir $HOME/.cache \
    --bind $HOME/.config/chromium $HOME/.config/chromium \
    --bind $HOME/Downloads $HOME/Downloads \
    --ro-bind /run/opengl-driver /run/opengl-driver \
    --ro-bind /run/user/$UID/bus /run/user/$UID/bus \
    --setenv FONTCONFIG_PATH /etc/fonts \
    /nix/store/9cm9481zw3zjd4jhp1d53cfbnliy4m8b-system-path/bin/strace -e 'trace=!clock_gettime,poll,write,futex,recvmsg,sendto,read,sendmsg,fallocate,ftruncate,gettimeofday,munmap,close,newfstatat,lseek,getpid,fcntl,dup,uname,madvise,mmap,socketpair,getpriority,gettid,mprotect,rt_sigprocmask,clone3,eventfd2,prlimit64,getegid,getuid,getgid,listen,getdents64,pread64,pwrite64,geteuid,pipe2,inotify_init' /nix/store/6yv5wvi1xi2n034r046xdzqnkhsh90f9-home-manager-path/bin/Discord --enable-features=UseOzonePlatform --ozone-platform=wayland
