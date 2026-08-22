{ pkgs, ... }:

{
  ###########################################################################
  # Direct port of `pacman -Qett` (59 explicit native) + `pacman -Qm` (AUR),
  # minus what's already handled as a NixOS service/program elsewhere.
  # Arch package name is noted wherever the nixpkgs attribute differs.
  ###########################################################################
  home.packages = with pkgs; [
    ##### Terminal & shell tooling ##########################################
    alacritty
    tmux
    bat                 # ~/.config/bat/config -> Catppuccin Mocha
    btop
    fd
    ripgrep
    fzf
    jq
    zoxide
    lazygit
    stow                # you still manage dotfiles with it — see dotfiles.nix
    tree
    unzip
    unrar               # unfree
    p7zip               # Arch: 7zip
    wget

    ##### Editors / IDEs ####################################################
    neovim
    vscode              # Arch AUR: visual-studio-code-bin (unfree)

    ##### Browsers ##########################################################
    firefox
    chromium

    ##### Desktop apps ######################################################
    obsidian            # unfree
    signal-desktop
    bitwarden-desktop   # Arch: bitwarden
    spotify             # unfree
    vlc
    localsend           # Arch AUR: localsend
    zoom-us             # Arch AUR: zoom (unfree)
    libreoffice-still
    galculator
    kdePackages.dolphin # Arch: dolphin
    kdePackages.ark     # archive handling from Dolphin
    kdePackages.kio-extras
    nsxiv               # Arch: sxiv (sxiv is unmaintained; nsxiv is the fork)

    ##### Creative ##########################################################
    blender
    musescore

    ##### Files / media utils ###############################################
    exiftool            # Arch: perl-image-exiftool
    imagemagick
    ffmpeg
    poppler-utils

    ##### AI / misc CLI #####################################################
    opencode            # Arch AUR: opencode-bin  (aliased to `ai` in your zshrc)
  ];
}
