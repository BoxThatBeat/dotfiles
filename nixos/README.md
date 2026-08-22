# NixOS configuration — `aaron-laptop`

A flake-based NixOS configuration reverse-engineered from the running Arch
install on this machine (HP ENVY x360 Convertible 15-bp0xx, Intel i5-7200U,
7.6 GiB RAM, 238 GiB NVMe), captured 2026-08-22.

**[INSTALL.md](./INSTALL.md)** is the step-by-step runbook for installing this
from a NixOS USB. **[MIGRATION.md](./MIGRATION.md)** lists the things that do
*not* have a clean Arch→Nix mapping and the decisions made on your behalf.
Read both before you start.

## What was carried over

| Area | Arch | NixOS |
|---|---|---|
| Boot | systemd-boot, ESP at `/boot`, `zswap.enabled=0 systemd.tpm2_wait=no` | `boot.loader.systemd-boot` + same `kernelParams` |
| Kernel | `linux` 7.1.5 (mainline), `linux-lts` as fallback | `linuxPackages_latest` |
| Microcode | `intel-ucode` | `hardware.cpu.intel.updateMicrocode` |
| Filesystems | ext4 `/`, vfat `/boot` | same UUIDs, hand-written `hardware-configuration.nix` |
| Swap | `zram-generator`, 3.8 G | `zramSwap`, zstd, 50 % |
| Network | systemd-networkd + iwd + resolved (no NetworkManager) | identical, `20-{ethernet,wlan,wwan}` ported with route metrics |
| Audio | PipeWire + pulse + alsa + WirePlumber, rtkit | `services.pipewire` |
| Graphics | i915, `intel-media-driver` + `libva-intel-driver`, multilib | `hardware.graphics` + `enable32Bit` |
| Desktop | Hyprland 0.56 (Lua config), SDDM, waybar, walker, swayosd, mako/dunst | `programs.hyprland` + `services.displayManager.sddm` |
| Portals | xdg-desktop-portal + hyprland + gtk | `xdg.portal` |
| Containers | docker.service, user in `docker` | `virtualisation.docker` |
| Games | steam + multilib | `programs.steam` |
| udev | ZSA, keyboard-drums, ipad_charge | `hardware.keyboard.zsa` + `services.udev.extraRules` |
| Locale | `en_US.UTF-8`, `Canada/Eastern`, us/pc105+inet | ported verbatim |
| User | `boxthatbeat` uid 1000, zsh, wheel/input/uucp/plugdev/docker | ported, plus `video`/`render`/`dialout` |

## Layout

```
nixos/
├── flake.nix                       nixpkgs-unstable + home-manager + nixos-hardware
├── hosts/aaron-laptop/
│   ├── default.nix                 hostname, stateVersion
│   └── hardware-configuration.nix  disks (real UUIDs), kernel modules, microcode
├── modules/nixos/                  system-level, imported wholesale
│   ├── nix.nix          flakes, GC, caches, allowUnfree
│   ├── boot.nix         systemd-boot, kernel, zram, modprobe
│   ├── locale.nix       timezone, locale, keymap
│   ├── networking.nix   networkd + iwd + resolved + firewall
│   ├── users.nix        the boxthatbeat account, polkit, rtkit
│   ├── graphics.nix     Intel/i915 + VA-API
│   ├── audio.nix        PipeWire
│   ├── bluetooth.nix    bluez
│   ├── power.nix        upower, TLP, thermald, lid behaviour
│   ├── desktop.nix      Hyprland, SDDM, portals, polkit agent, hypr* tools
│   ├── fonts.nix        JetBrains Mono + Nerd Font + Noto + fontconfig
│   ├── udev.nix         ZSA / keyboard-drums / ipad_charge rules
│   ├── virtualisation.nix  docker
│   ├── services.nix     fstrim, timesyncd, journald caps, steam, nix-ld
│   └── packages.nix     rescue-shell / machine-level tools only
└── modules/home/                   home-manager for boxthatbeat
    ├── packages.nix     your apps, one-to-one with `pacman -Qett` + AUR
    ├── shell.nix        zsh/oh-my-zsh/p10k packages, env vars, PATH
    ├── git.nix          ~/.gitconfig
    ├── dev.nix          toolchains + every LSP you currently get from Mason
    ├── dotfiles.nix     stow-vs-home-manager choice + battery-notify service
    └── xdg.nix          user dirs + mimeapps.list
```

## Installing

See **[INSTALL.md](./INSTALL.md)**. The short version:

1. Push this repo, then prove it builds while Arch still works:
   `nix build --dry-run .#nixosConfigurations.aaron-laptop.config.system.build.toplevel`
2. Back up `/home` to an external drive — 124 GB, and this laptop has one disk.
3. Boot the USB, get wifi up, repartition with a 2 GB ESP labelled `BOOT` and a
   root labelled `nixos`.
4. Clone the repo to `/mnt/home/boxthatbeat/dotfiles`, set `stateVersion`, and
   `nixos-install --flake /mnt/home/boxthatbeat/dotfiles/nixos#aaron-laptop`.
5. Reboot, set your password from a TTY, `stow` your dotfiles.

## Day-to-day

```sh
# rebuild after editing anything under nixos/
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#aaron-laptop

# test without making it the boot default
sudo nixos-rebuild test --flake ~/dotfiles/nixos#aaron-laptop

# update everything (the equivalent of `pacman -Syu` + `yay -Sua`)
nix flake update --flake ~/dotfiles/nixos
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#aaron-laptop

# roll back — the thing Arch never gave you
sudo nixos-rebuild switch --rollback
```

`home-manager` is wired in as a NixOS module, so `nixos-rebuild switch` applies
your user config too; there is no separate `home-manager switch` step.

## Verifying attribute names first

This config was written offline, so a few package attributes are educated
guesses. Check them all in one go before your first install:

```sh
for p in walker fuzzel opencode hyprshot hypridle hyprlock hyprsunset swayosd \
         bitwarden-desktop localsend zoom-us nsxiv musescore libreoffice-still \
         taskwarrior-tui vtsls tailwindcss-language-server vscode-js-debug \
         markdownlint-cli2 marksman nixd gcc-arm-embedded adwaita-fonts; do
  nix eval --raw "nixpkgs#$p.name" 2>/dev/null && echo "  <- $p OK" || echo "MISSING: $p"
done

# Hyprland must be >= 0.55 for your Lua config to load at all:
nix eval --raw nixpkgs#hyprland.version
```

Anything reported MISSING is listed with a workaround in
[MIGRATION.md](./MIGRATION.md).
