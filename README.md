
flatpak install --assumeyes flathub org.mozilla.firefox
flatpak install --assumeyes flathub com.valvesoftware.Steam
flatpak install --assumeyes flathub com.discordapp.Discord
flatpak install --assumeyes flathub com.heroicgameslauncher.hgl
flatpak install --assumeyes flathub org.videolan.VLC
flatpak install --assumeyes flathub com.google.Chrome
flatpak install --assumeyes flathub com.visualstudio.code
flatpak install --assumeyes flathub org.gimp.GIMP
flatpak install --assumeyes flathub org.libreoffice.LibreOffice

flatpak install --assumeyes flathub com.vscodium.codium
flatpak override --user com.vscodium.codium --no-talk-name=org.freedesktop.Flatpak
flatpak override --user com.vscodium.codium --nofilesystem=home