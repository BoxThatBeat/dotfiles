{ pkgs, ... }:

{
  # Arch had pipewire + pipewire-pulse + pipewire-alsa + wireplumber, with the
  # user units pipewire.socket / pipewire-pulse.socket / wireplumber.service enabled.
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # Steam
    pulse.enable = true;
    jack.enable = false;
    wireplumber.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pavucontrol   # you had it explicitly installed
    playerctl     # waybar/media keybinds in base/bindings/media.lua
    pamixer
  ];
}
