-- Autostart processes. See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- The .conf `exec-once` keyword is now a callback on the `hyprland.start` event.

hl.on("hyprland.start", function()
  -- hl.exec_cmd("uwsm-app -- hypridle")
  -- hl.exec_cmd("uwsm-app -- mako")
  hl.exec_cmd("waybar")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("elephant")
  hl.exec_cmd("walker --gapplication-service")
  hl.exec_cmd("swayosd-server")
  -- hl.exec_cmd("uwsm-app -- fcitx5")
  -- hl.exec_cmd("uwsm-app -- swaybg -i ~/.config/omarchy/current/background -m fill")
  -- hl.exec_cmd("uwsm-app -- swayosd-server")
  -- hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  -- hl.exec_cmd("omarchy-cmd-first-run")

  -- Slow app launch fix -- set systemd vars
  -- hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
  -- hl.exec_cmd("dbus-update-activation-environment --systemd --all")
end)
