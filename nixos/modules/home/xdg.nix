{ config, lib, ... }:

{
  xdg.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    # Matches the dirs that already exist in your $HOME.
    documents = "${config.home.homeDirectory}/Documents";
    download  = "${config.home.homeDirectory}/Downloads";
    music     = "${config.home.homeDirectory}/Music";
    pictures  = "${config.home.homeDirectory}/Pictures";
    videos    = "${config.home.homeDirectory}/Videos";
    desktop   = null;
    publicShare = null;
    templates = null;
  };

  # Ported from ~/.config/mimeapps.list
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "audio/mpeg" = [ "vlc.desktop" ];
      "video/mp4" = [ "vlc.desktop" ];
      "x-scheme-handler/mailto" = [ "chromium-browser.desktop" ];
      # Your Arch file also had x-scheme-handler/claude-cli — that .desktop is
      # installed by the Claude Code CLI itself, so it will reappear on its own.
    };
  };

  # base/envs.lua points XCOMPOSEFILE at ~/.XCompose, and base/input.lua binds
  # Caps Lock as the Compose key. The file itself isn't in your dotfiles repo —
  # if you rely on custom sequences, add it there and stow it.
}
