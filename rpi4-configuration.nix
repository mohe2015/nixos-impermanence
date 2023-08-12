{ pkgs, lib, ... }:

{
  # nested aarch64 virtualization is not nice
  nixpkgs.system = "aarch64-linux";
  # https://gcc.gnu.org/onlinedocs/gccint/Configure-Terms.html
  #nixpkgs.buildPlatform = "x86_64-linux";
  #nixpkgs.hostPlatform = "aarch64-linux";
  documentation.nixos.enable = false;
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "vfat" ];
  sdImage.compressImage = false;

  hardware.opengl = {
    enable = true;
    setLdLibraryPath = true;
    package = pkgs.mesa_drivers;
  };
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    videoDrivers = [ "modesetting" ];
  };

  boot.loader.raspberryPi.firmwareConfig = ''
    gpu_mem=192
  '';

  system.stateVersion = "23.11";
}