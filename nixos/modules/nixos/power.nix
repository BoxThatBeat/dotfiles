{ pkgs, ... }:

{
  # Arch had upower.service running (waybar's battery module uses it), plus a
  # hand-rolled ~/.config/hypr/scripts/battery-notify.sh polling loop.
  services.upower = {
    enable = true;
    percentageLow = 20;      # matches WARN_LEVEL in battery-notify.sh
    percentageCritical = 10; # matches CRITICAL_LEVEL
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };

  # You had NO tlp/thermald/power-profiles-daemon on Arch, so this is an
  # addition rather than a port. TLP is a clear win on a 2017 Kaby Lake laptop.
  # If you'd rather keep parity with Arch, set this to false.
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      # This HP has no charge-threshold support in F.08 firmware; omitted on purpose.
    };
  };
  # TLP and power-profiles-daemon are mutually exclusive.
  services.power-profiles-daemon.enable = false;

  services.thermald.enable = true; # Intel-specific, harmless, helps thermal throttle

  # Lid + power button behaviour. Arch used the systemd defaults (empty
  # /etc/systemd/logind.conf), so these ARE the defaults, written out explicitly.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "poweroff";
  };

  # brightnessctl was an explicit Arch package; this also installs the udev
  # rules that let a non-root `video` group member set brightness.
  environment.systemPackages = with pkgs; [ brightnessctl powertop ];
}
