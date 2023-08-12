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

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  users.mutableUsers = false;

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

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
  };

  system.stateVersion = "23.11";
}