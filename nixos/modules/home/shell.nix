{ config, pkgs, lib, ... }:

{
  ###########################################################################
  # Your Arch setup: zsh + oh-my-zsh (cloned into ~/.oh-my-zsh) + powerlevel10k
  # + ~/.p10k.zsh from the dotfiles repo.
  #
  # This module reproduces that declaratively. It intentionally does NOT write
  # ~/.zshrc from Nix — your dotfiles repo owns that file via stow, and this
  # keeps a single source of truth. What Nix provides instead is the *packages*
  # (oh-my-zsh, powerlevel10k) at stable store paths, exported as env vars your
  # .zshrc can point at.
  #
  # To let Nix own .zshrc entirely, set `programs.zsh.enable = true` below and
  # migrate the contents; see the commented block at the bottom.
  ###########################################################################

  home.packages = with pkgs; [
    zsh
    oh-my-zsh
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
  ];

  # Your .zshrc does `export ZSH="$HOME/.oh-my-zsh"` and
  # `ZSH_THEME="powerlevel10k/powerlevel10k"`. On NixOS the store paths differ.
  # Add this to the top of your stow'd .zshrc to make it portable:
  #
  #   export ZSH="${ZSH_NIX:-$HOME/.oh-my-zsh}"
  #   if [ -n "$P10K_NIX" ]; then
  #     source "$P10K_NIX/powerlevel10k.zsh-theme"
  #   else
  #     ZSH_THEME="powerlevel10k/powerlevel10k"
  #   fi
  #
  # ...and it will keep working unchanged back on Arch.
  home.sessionVariables = {
    ZSH_NIX = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    P10K_NIX = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";

    # From your .zshrc
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    EDITOR = "nvim";
    VISUAL = "nvim";

    # base/envs.lua sets these for the Hyprland session; repeating them here
    # covers TTY logins and systemd user services too.
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    XCOMPOSEFILE = "${config.home.homeDirectory}/.XCompose";
  };

  # Your zshrc appends these to PATH. Home-manager manages PATH properly:
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/go/bin"
  ];

  ###########################################################################
  # Optional: let home-manager own .zshrc instead of stow.
  # If you enable this, remove `zsh` from your stow list to avoid a conflict.
  ###########################################################################
  # programs.zsh = {
  #   enable = true;
  #   autosuggestion.enable = true;
  #   syntaxHighlighting.enable = true;
  #   oh-my-zsh = {
  #     enable = true;
  #     plugins = [ "git" ];
  #     theme = "";            # p10k is loaded via the plugin below instead
  #   };
  #   plugins = [{
  #     name = "powerlevel10k";
  #     src = pkgs.zsh-powerlevel10k;
  #     file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  #   }];
  #   shellAliases = {
  #     cd = "z"; vim = "nvim"; vi = "nvim"; lzg = "lazygit"; ai = "opencode";
  #   };
  #   initContent = ''
  #     chpwd() { ls; }
  #     [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  #   '';
  # };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd z" ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

}
