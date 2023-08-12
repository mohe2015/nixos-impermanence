{ pkgs }:

{
  # nested aarch64 virtualization is not nice
  nixpkgs.system = "aarch64-linux";
  # https://gcc.gnu.org/onlinedocs/gccint/Configure-Terms.html
  #nixpkgs.buildPlatform = "x86_64-linux";
  #nixpkgs.hostPlatform = "aarch64-linux";
  documentation.nixos.enable = false;
  boot.supportedFilesystems = nixpkgs.lib.mkForce [ "btrfs" "vfat" ];
  sdImage.compressImage = false;
  system.stateVersion = "23.11";

  networking.wireless.enable = false;
  hardware.opengl = {
    enable = true;
    setLdLibraryPath = true;
    package = pkgs.mesa_drivers;
  };
  hardware.deviceTree = {
    base = pkgs.device-tree_rpi;
    overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
  };
  services.xserver = {
    enable = true;
    displayManager.slim.enable = true;
    desktopManager.gnome3.enable = true;
    videoDrivers = [ "modesetting" ];
  };
}