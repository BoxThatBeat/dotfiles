{ config, lib, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";

  # `mkOutOfStoreSymlink` points at the live path in your git checkout rather
  # than copying into /nix/store, so configs stay editable exactly like stow.
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  ###########################################################################
  # Two ways to get your configs into place. Pick ONE.
  #
  # (A) KEEP STOW — the default. Nothing here is active; you run
  #         cd ~/dotfiles && stow alacritty bat btop hypr nvim tmux waybar \
  #                              walker elephant task pomo keyboard-drums zsh
  #     exactly as you do on Arch. Zero behaviour change, and the repo stays
  #     usable from a non-Nix machine.
  #
  # (B) LET HOME-MANAGER LINK THEM — uncomment the block below and drop stow.
  #     Benefit: `home-manager switch` becomes the single source of truth and
  #     it errors loudly on conflicts instead of silently skipping like stow.
  #     Still out-of-store, so configs remain live-editable.
  ###########################################################################

  # ---- (B) -----------------------------------------------------------------
  # xdg.configFile = {
  #   "alacritty".source       = link "alacritty/.config/alacritty";
  #   "bat".source             = link "bat/.config/bat";
  #   "btop".source            = link "btop/.config/btop";
  #   "hypr".source            = link "hypr/.config/hypr";
  #   "nvim".source            = link "nvim/.config/nvim";
  #   "tmux".source            = link "tmux/.config/tmux";
  #   "waybar".source          = link "waybar/.config/waybar";
  #   "walker".source          = link "walker/.config/walker";
  #   "elephant".source        = link "elephant/.config/elephant";
  #   "task".source            = link "task/.config/task";
  #   "pomo".source            = link "pomo/.config/pomo";
  #   "keyboard-drums".source  = link "keyboard-drums/.config/keyboard-drums";
  # };
  # home.file.".zshrc".source    = link "zsh/.zshrc";
  # home.file.".p10k.zsh".source = link "zsh/.p10k.zsh";
  # --------------------------------------------------------------------------

  # `autostart.lua` runs ~/.config/hypr/scripts/battery-notify.sh, which uses
  # notify-send. libnotify is installed in modules/nixos/desktop.nix.
}
