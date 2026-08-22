{ pkgs, ... }:

{
  # Arch: bluez + bluez-utils, bluetooth.service enabled and running.
  # Your waybar config has a `bluetooth` module, which reads from bluez directly.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Lets headsets show battery level and improves reconnect behaviour.
        Experimental = true;
        FastConnectable = true;
      };
    };
  };

  # Optional tray/GUI. Uncomment if you want more than `bluetoothctl`.
  # services.blueman.enable = true;

  environment.systemPackages = with pkgs; [ bluez bluez-tools ];
}
