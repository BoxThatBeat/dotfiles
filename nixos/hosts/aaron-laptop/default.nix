{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  networking.hostName = "aaron-laptop";

  # The NixOS release you FIRST install from. Never change it afterwards — it
  # pins stateful defaults (database versions and the like), not package
  # versions. Confirm with `nixos-version` on the installer and adjust if your
  # USB is a different release.
  system.stateVersion = "26.05";
}
