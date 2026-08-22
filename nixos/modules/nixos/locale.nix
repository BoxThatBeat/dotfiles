{ ... }:

{
  # /etc/localtime -> Canada/Eastern
  time.timeZone = "Canada/Eastern";

  # /etc/locale.conf: LANG=en_US.UTF-8 ; locale.gen: en_US.UTF-8 UTF-8
  i18n.defaultLocale = "en_US.UTF-8";

  # /etc/vconsole.conf: KEYMAP=us
  console.keyMap = "us";

  # /etc/X11/xorg.conf.d/00-keyboard.conf, written by systemd-localed:
  #   XkbLayout=us, XkbModel=pc105+inet, XkbOptions=terminate:ctrl_alt_bksp
  # This feeds XWayland and SDDM. Hyprland's own kb_options live in your
  # dotfiles (base/input.lua sets `compose:caps`).
  services.xserver.xkb = {
    layout = "us";
    model = "pc105+inet";
    options = "terminate:ctrl_alt_bksp";
  };
}
