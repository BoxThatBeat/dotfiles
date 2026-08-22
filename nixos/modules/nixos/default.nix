{ ... }:

{
  imports = [
    ./nix.nix
    ./boot.nix
    ./locale.nix
    ./networking.nix
    ./users.nix
    ./graphics.nix
    ./audio.nix
    ./bluetooth.nix
    ./power.nix
    ./desktop.nix
    ./fonts.nix
    ./udev.nix
    ./virtualisation.nix
    ./packages.nix
    ./services.nix
  ];
}
