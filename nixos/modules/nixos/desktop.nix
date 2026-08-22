{ pkgs, lib, inputs, ... }:

{
  ###########################################################################
  # Hyprland. The pinned nixpkgs gives 0.56.2 — the same version you run on
  # Arch, so the Lua config in ~/.config/hypr loads as-is. If a future
  # `nix flake update` ever drags this below 0.55, the Lua format stops being
  # understood and the session comes up unconfigured; re-check with
  # `nix eval nixpkgs#hyprland.version` after big updates.
  ###########################################################################
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # base/envs.lua sets xwayland.force_zero_scaling
    withUWSM = false;       # your autostart has the uwsm-app lines commented out
  };

  # SDDM was your display manager (sddm.service enabled). Run it on Wayland so
  # it doesn't drag in a full X server.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    autoNumlock = false; # base/input.lua: numlock_by_default = false
  };
  services.displayManager.defaultSession = "hyprland";

  # Arch had seatd.service enabled. On NixOS, systemd-logind provides seat
  # management for Hyprland out of the box and running seatd alongside it is
  # redundant. Left off deliberately — enable only if you hit seat errors:
  # services.seatd.enable = true;

  # xdg-desktop-portal + -hyprland + -gtk were all installed on Arch.
  # `programs.hyprland` already wires up the hyprland portal; add GTK for
  # file pickers (Firefox/Chromium/Electron "Open File" dialogs).
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  # polkit-kde-agent was an explicit Arch package. Hyprland needs an agent
  # running for GUI privilege prompts (e.g. Dolphin mounting a disk).
  systemd.user.services.polkit-kde-authentication-agent-1 = {
    description = "polkit-kde-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # mako is D-Bus-activated on org.freedesktop.Notifications, exactly as it was
  # under Arch's mako.service. These two lines register the unit and the
  # activation file so the first notify-send starts it.
  systemd.packages = [ pkgs.mako ];
  services.dbus.packages = [ pkgs.mako ];

  # GTK/dconf settings need this or GTK apps fall back to defaults every launch.
  programs.dconf.enable = true;

  # Needed so Dolphin can mount USB sticks and show trash.
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Secrets for Chromium/Electron apps that expect an org.freedesktop.secrets
  # provider. On Arch this came from kwallet (installed as a Dolphin dep).
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # gnome-keyring turns on gcr-ssh-agent by default, which cannot coexist with
  # programs.ssh.startAgent. Arch used the plain ssh-agent.socket user unit and
  # your .zshrc manages SSH_AUTH_SOCK itself, so keep that and turn gcr off.
  services.gnome.gcr-ssh-agent.enable = false;

  environment.systemPackages = with pkgs; [
    # Hyprland ecosystem — matches the configs already in your dotfiles
    hyprpaper       # hyprpaper.conf -> ~/Images/wallpapers/thinkpad.png
    hyprlock        # hyprlock.conf exists (currently commented out)
    hypridle        # hypridle.conf exists (currently commented out)
    hyprsunset      # hyprsunset.conf exists
    hyprshot        # Arch: hyprshot-git, bound in base/apps/hyprshot.lua
    hyprpicker
    hyprcursor
    kdePackages.polkit-kde-agent-1

    # Bar / notifications / OSD, all autostarted from base/autostart.lua
    waybar
    mako
    libnotify       # `notify-send`, used by battery-notify.sh
    swayosd         # base/autostart.lua: swayosd-server

    # Launcher. Both are the same versions you run on Arch: walker 2.17.0 and
    # its provider daemon elephant 2.22.0, which ships desktopapplications.so
    # and calc.so to match your ~/.config/elephant.
    walker
    elephant

    # Spare launcher, in case you ever want to compare. Not autostarted.
    fuzzel

    # Clipboard — base/bindings/clipboard.lua
    wl-clipboard
    cliphist

    # Screenshot primitives hyprshot shells out to
    grim
    slurp

    # XWayland/session glue
    kdePackages.qtwayland   # Arch: qt6-wayland
    qt5.qtwayland
    xorg.xrandr
    wlr-randr
  ];
}
