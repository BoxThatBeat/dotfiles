{ pkgs, ... }:

{
  # Intel Kaby Lake-U GT2 [HD Graphics 620], i915.
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam + lib32 (you had multilib enabled in pacman.conf)

    extraPackages = with pkgs; [
      intel-media-driver   # iHD  — Arch: intel-media-driver
      intel-vaapi-driver   # i965 — Arch: libva-intel-driver (Kaby Lake works with both)
      libvdpau-va-gl
    ];
    # 32-bit only needs the legacy i965 driver for Steam titles; the iHD
    # driver has no reliable 32-bit build.
    extraPackages32 = with pkgs.pkgsi686Linux; [ intel-vaapi-driver ];
  };

  # iHD is the better driver on Kaby Lake; be explicit so VLC/Firefox/Chromium agree.
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  environment.systemPackages = with pkgs; [
    libva-utils   # `vainfo` to verify hardware decode after switching
    intel-gpu-tools
    vulkan-tools
  ];
}
