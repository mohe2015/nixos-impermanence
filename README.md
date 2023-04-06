
flatpak install --assumeyes flathub org.mozilla.firefox
flatpak install --assumeyes flathub com.valvesoftware.Steam

# needed for krisp and without its bad
flatpak install --assumeyes flathub com.discordapp.Discord

flatpak install --assumeyes flathub com.heroicgameslauncher.hgl
flatpak install --assumeyes flathub org.videolan.VLC

flatpak install --assumeyes flathub org.chromium.Chromium

flatpak install --assumeyes flathub com.visualstudio.code
flatpak install --assumeyes flathub org.gimp.GIMP
flatpak install --assumeyes flathub org.libreoffice.LibreOffice
flatpak install --assumeyes flathub org.mozilla.Thunderbird

# see needed runtime-version in https://github.com/flathub/com.vscodium.codium/blob/master/com.vscodium.codium.yaml
flatpak install flathub org.freedesktop.Sdk.Extension.rust-stable
flatpak install --assumeyes flathub com.vscodium.codium
flatpak override --user com.vscodium.codium --nofilesystem=home
flatpak override --user --env=FLATPAK_ENABLE_SDK_EXT=rust-stable com.vscodium.codium
flatpak run com.vscodium.codium


https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/build-fhs-userenv-bubblewrap/default.nix
exportReferencesGraph/closureInfo
https://git.sr.ht/~fgaz/nix-bubblewrap/tree/master/item/nix-bwrap.tcl

https://github.com/containers/bubblewrap