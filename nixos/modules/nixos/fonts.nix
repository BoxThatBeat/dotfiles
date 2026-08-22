{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # Explicitly installed on Arch — your terminal/waybar font.
      jetbrains-mono
      nerd-fonts.jetbrains-mono   # Arch: ttf-jetbrains-mono-nerd
                                  # (waybar/hypr use nerd glyphs like 󰁹 󰤨 󱓻)

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji            # Arch: noto-fonts-emoji

      liberation_ttf              # Arch: ttf-liberation
      gnu-free-fonts              # Arch: gnu-free-fonts
      adwaita-fonts               # Arch: adwaita-fonts (GTK default UI font)

      font-awesome                # waybar icon fallback
      corefonts                   # LibreOffice document fidelity
    ];

    fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;
      hinting.style = "slight";
      subpixel.rgba = "rgb";
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "JetBrains Mono" "Noto Sans Mono" ];
        sansSerif = [ "Adwaita Sans" "Noto Sans" ];
        serif     = [ "Noto Serif" ];
        emoji     = [ "Noto Color Emoji" ];
      };
    };
  };
}
