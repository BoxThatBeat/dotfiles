{ pkgs, ... }:

{
  ###########################################################################
  # System-level packages only: things that must exist for root/rescue, or
  # that belong to the machine rather than to you.
  #
  # Everything you interact with day-to-day (editors, browsers, CLI tools,
  # GUI apps) lives in ../home/packages.nix instead, so `home-manager switch`
  # can iterate on them without a full system rebuild.
  ###########################################################################

  environment.systemPackages = with pkgs; [
    # Arch `base` group equivalents you'd want in a broken-boot shell
    coreutils
    util-linux
    pciutils
    usbutils
    lm_sensors
    dosfstools
    e2fsprogs
    smartmontools

    # Bootloader management — Arch: efibootmgr
    efibootmgr

    # Arch: nano (kept as the "it's 3am and something is broken" editor)
    nano
    vim

    git       # needed at system level for flake operations
    wget
    curl
    rsync

    # Arch: evtest — used with keyboard-drums to identify input devices
    evtest

    # Arch: wireless_tools (iw is the modern replacement)
    iw
    ethtool

    man-pages
    man-pages-posix
  ];

  # `programs.*` versions register shell completion and set up wrappers properly.
  programs.command-not-found.enable = false; # needs a channel; nix-index is better
  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

  documentation = {
    enable = true;
    man.enable = true;
    dev.enable = true;
  };

  environment.variables.EDITOR = "nvim";
}
