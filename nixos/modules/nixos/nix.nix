{ inputs, lib, pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    # `wheel` is trusted so you can use binary caches / `nix develop` freely.
    trusted-users = [ "root" "@wheel" ];
    # Arch had ParallelDownloads = 5; the Nix equivalent:
    max-jobs = "auto";
    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  # Keep the store from growing without bound. Arch had no equivalent; this is
  # the NixOS hygiene you actually want on a 238G disk.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Pin the system's `nixpkgs` (for `nix shell nixpkgs#foo`, nix-shell, etc.)
  # to the exact revision this flake was built from.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # spotify, vscode, zoom-us, obsidian, steam are all unfree.
  nixpkgs.config.allowUnfree = true;

  system.autoUpgrade.enable = false; # rolling, but on your terms — like Arch
}
