{ pkgs, lib, ... }:

{
  networking.hostName = "rpi4";

  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXOS_SD";
      fsType = lib.mkForce "btrfs";
      options = [ "compress-force=zstd" ];
    };

  nixpkgs.system = "aarch64-linux";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.supportedFilesystems = lib.mkForce [ "btrfs" "vfat" ];

  hardware.deviceTree.enable = true;
  hardware.raspberry-pi."4".fkms-3d.enable = true;
  hardware.raspberry-pi."4".touch-ft5406.enable = true;
  hardware.raspberry-pi."4".backlight.enable = true;
  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;

  # gnome is too big for touchscreen
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
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

  environment.systemPackages = with pkgs; [
    git
    libraspberrypi
    raspberrypi-eeprom
  ];

  system.stateVersion = "23.11";
}
