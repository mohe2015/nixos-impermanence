



https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/build-fhs-userenv-bubblewrap/default.nix
exportReferencesGraph/closureInfo
https://git.sr.ht/~fgaz/nix-bubblewrap/tree/master/item/nix-bwrap.tcl

https://github.com/containers/bubblewrap

bwrap --unshare-all --clearenv --new-session --die-with-parent --dev-bind / / /nix/store/6yv5wvi1xi2n034r046xdzqnkhsh90f9-home-manager-path/bin/Discord

https://github.com/valoq/bwscripts/blob/master/profiles/signal-desktop

https://wiki.archlinux.org/title/Bubblewrap
https://wiki.archlinux.org/title/Bubblewrap/Examples

https://wiki.archlinux.org/title/Bubblewrap/Examples

bwrap \
    --ro-bind /etc /etc \
    --unshare-all --clearenv --new-session --die-with-parent --ro-bind /nix/store /nix/store \
    --ro-bind "$XDG_RUNTIME_DIR/wayland-0" "$XDG_RUNTIME_DIR/wayland-0" \
    --ro-bind "$XDG_RUNTIME_DIR/pipewire-0" "$XDG_RUNTIME_DIR/pipewire-0" \
    --ro-bind "$XDG_RUNTIME_DIR/pulse" "$XDG_RUNTIME_DIR/pulse" \
    /nix/store/39d1qwkrdm00fvcp6l0znkq7kz8bvyrz-home-manager-path/bin/chromium --enable-features=UseOzonePlatform --ozone-platform=wayland

bwrap --unshare-all --clearenv --new-session --die-with-parent --ro-bind /nix/store /nix/store /nix/store/6yv5wvi1xi2n034r046xdzqnkhsh90f9-home-manager-path/bin/Discord
