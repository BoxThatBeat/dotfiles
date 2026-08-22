# Hand-written from the live Arch system. After you boot the NixOS installer,
# run `nixos-generate-config --root /mnt` and diff its output against this file —
# if it disagrees about kernel modules, trust the generator.
#
# Observed layout on the Arch install (lsblk / fstab, 2026-08-22):
#   nvme0n1        238.5G
#   ├─nvme0n1p1      1G  vfat  ->  /boot   UUID=9BAC-8D5E
#   └─nvme0n1p2  237.5G  ext4  ->  /       UUID=2cb659a0-14db-4dd8-8d2a-1a4437e65847
#   zram0          3.8G  swap  (generated, see modules/nixos/boot.nix)
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2cb659a0-14db-4dd8-8d2a-1a4437e65847";
    fsType = "ext4";
    options = [ "rw" "relatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9BAC-8D5E";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # No swap partition — swap is zram only (matches the Arch zram-generator setup).
  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault false; # handled explicitly by systemd-networkd

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Intel Core i5-7200U (Kaby Lake). Was `intel-ucode` on Arch.
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
}
