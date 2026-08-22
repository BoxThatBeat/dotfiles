{ ... }:

{
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./dev.nix
    ./dotfiles.nix
    ./xdg.nix
  ];

  home.username = "boxthatbeat";
  home.homeDirectory = "/home/boxthatbeat";

  # Same rule as system.stateVersion: set once, then leave alone.
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
