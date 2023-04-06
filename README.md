



https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/build-fhs-userenv-bubblewrap/default.nix
exportReferencesGraph/closureInfo
https://git.sr.ht/~fgaz/nix-bubblewrap/tree/master/item/nix-bwrap.tcl

https://github.com/containers/bubblewrap

bwrap --unshare-all --unshare-user --disable-userns --assert-userns-disabled --clearenv --new-session --die-with-parent --dev-bind / / /nix/store/6yv5wvi1xi2n034r046xdzqnkhsh90f9-home-manager-path/bin/Discord

https://github.com/valoq/bwscripts/blob/master/profiles/signal-desktop

https://wiki.archlinux.org/title/Bubblewrap
https://wiki.archlinux.org/title/Bubblewrap/Examples

https://wiki.archlinux.org/title/Bubblewrap/Examples

bwrap \
    --symlink usr/lib /lib \
    --symlink usr/lib64 /lib64 \
    --symlink usr/bin /bin \
    --symlink usr/bin /sbin \
    --ro-bind /usr/bin /usr/bin \
    --ro-bind /etc /etc \
    --ro-bind /nix/store /nix/store \
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
    --bind $HOME/Downloads $HOME/Downloads \
    /nix/store/39d1qwkrdm00fvcp6l0znkq7kz8bvyrz-home-manager-path/bin/chromium --enable-features=UseOzonePlatform --ozone-platform=wayland