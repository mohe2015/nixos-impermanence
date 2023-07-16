# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=16G" "mode=755" ];
  };

  fileSystems."/home/moritz" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=16G" "mode=777" ];
  };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-uuid/0ff279a2-8c85-4de8-96fb-d8f9277ef5fd";
      fsType = "ext4";
      neededForBoot = true;
    };

  boot.initrd.luks.devices."luks-ccc3fe28-de24-45df-98c7-b3674b8da815".device = "/dev/disk/by-uuid/ccc3fe28-de24-45df-98c7-b3674b8da815";

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/61D0-4CB9";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/c9534520-b58d-4bc2-9a51-0978fd64e1ce"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
