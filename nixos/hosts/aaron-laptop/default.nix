{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  networking.hostName = "aaron-laptop";

  # Set this to the NixOS release you FIRST installed from and then never change
  # it. If you install from a 26.05 ISO, change this to "26.05" before the first
  # `nixos-install` — it controls stateful defaults (database versions, etc.).
  system.stateVersion = "25.11";
}
