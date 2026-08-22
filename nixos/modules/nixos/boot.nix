{ pkgs, lib, ... }:

{
  # Arch used systemd-boot with an ESP at /boot (created by archinstall).
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10; # don't let the ESP fill with generations
    consoleMode = "keep";    # matches the commented `#console-mode keep`
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3; # matches loader.conf `timeout 3`

  # You were running the mainline `linux` package (7.1.5-arch1), not the LTS
  # default. Keep that. Swap to `pkgs.linuxPackages` for the NixOS LTS default,
  # which is the safer choice on this 2017 Kaby Lake machine if you hit regressions.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Carried over verbatim from your systemd-boot entries.
  #   zswap.enabled=0     -> zswap off because you use zram instead
  #   systemd.tpm2_wait=no-> this HP's F.08 firmware (2017) has no usable TPM2
  boot.kernelParams = [
    "zswap.enabled=0"
    "systemd.tpm2_wait=no"
  ];

  # Arch: HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole ...)
  # The `systemd` + `sd-vconsole` hooks map onto systemd-in-initrd here.
  boot.initrd.systemd.enable = true;

  # /etc/modprobe.d/psmouse.conf — enables Intertouch on the Synaptics touchpad.
  boot.extraModprobeConfig = ''
    options psmouse synaptics_intertouch=1
  '';

  # Replaces the `zram-generator` package + /etc/systemd/zram-generator.conf.
  # Arch's default gave you 3.8G on 7.6G RAM, i.e. 50%.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # 7.6G of RAM on this machine — tmpfs /tmp would fight with builds.
  boot.tmp.cleanOnBoot = true;
}
