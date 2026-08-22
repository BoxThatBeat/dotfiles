{ pkgs, ... }:

{
  ###########################################################################
  # Ports of everything in /etc/udev/rules.d on the Arch box.
  # (70-snap.snapd.rules is intentionally NOT ported — see MIGRATION.md.)
  ###########################################################################

  # /etc/udev/rules.d/50-zsa.rules — ZSA Moonlander/Ergodox/Planck/Voyager
  # flashing + Oryx live training. NixOS ships this as a first-class option,
  # which installs the identical upstream rules and creates the group.
  hardware.keyboard.zsa.enable = true;

  services.udev.extraRules = ''
    # --- /etc/udev/rules.d/99-keyboard-drums.rules ---
    # Grants the `input` group read access to /dev/input/event* so
    # keyboard-drums can read key events without running as root.
    KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="input"

    # --- /etc/udev/rules.d/95-ipad_charge.rules ---
    # Bumps USB current draw so an iPad actually charges from this laptop.
    # NOTE: `ipad_charge` is an AUR package with no nixpkgs equivalent. These
    # rules are inert until you package it — see MIGRATION.md. The path below
    # assumes you drop a build into pkgs/ipad-charge and add it to
    # environment.systemPackages; until then udev will just log a missing RUN.
    ENV{DEVTYPE}=="usb_device", ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="129a", RUN+="/run/current-system/sw/bin/ipad_charge"
    ENV{DEVTYPE}=="usb_device", ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="129f", RUN+="/run/current-system/sw/bin/ipad_charge"
    ENV{DEVTYPE}=="usb_device", ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="12a2", RUN+="/run/current-system/sw/bin/ipad_charge"
    ENV{DEVTYPE}=="usb_device", ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="12a4", RUN+="/run/current-system/sw/bin/ipad_charge"
  '';

  # You have arm-none-eabi-gcc and a Betaflight blackbox log in ~ — you flash
  # STM32 boards. This gives non-root access to DFU/serial bootloaders.
  services.udev.packages = with pkgs; [
    stlink
    openocd
  ];
}
