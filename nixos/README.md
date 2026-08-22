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

## Which channel

Currently **`nixos-unstable`**, which today evaluates as `26.11` "Zokor"
pre-release. Current stable is `nixos-26.05`.

Both work. Your Lua hypr config needs Hyprland >= 0.55 and stable ships 0.55.4,
so that is not the deciding factor. What you actually trade:

| | unstable (current) | stable 26.05 |
|---|---|---|
| Hyprland | 0.56.2 — same as your Arch | 0.55.4 |
| walker / elephant | 2.17.0 / 2.22.0 | 2.16.2 / 2.21.0 |
| opencode | 1.18.18 | 1.15.10 |
| vscode | 1.133.0 | 1.119.0 |
| `nix flake update` | can break evaluation | rarely does |
| security fixes | as they land | backported |

Staying on unstable is the recommendation: it matches the rolling model you are
used to from Arch, and it is the only channel that gives you the exact Hyprland
you run today, so day one is a straight port with no version delta.

The usual objection to rolling — "an update breaks my machine" — mostly does not
apply here. On Arch a bad update breaks the system you are running. On NixOS a
bad update either fails at evaluation before anything changes (as the first
attempt at this config did, on three renamed options) or leaves the previous
generation in the boot menu. Updating is also an explicit act, not a
consequence of installing something.

To switch to stable, change one line in `flake.nix`:

```nix
nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
```

then `nix flake update` and re-run the dry build. Nothing else in this config
is channel-specific.

`stateVersion` is set to `26.05` in `hosts/aaron-laptop/default.nix` and
`modules/home/default.nix`. That is not the channel — it pins stateful defaults
and should match the release you first install from, then never change.

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

## Verified against real nixpkgs

This config was written offline, then checked with a full evaluation against the
pinned nixpkgs (`nixos-unstable`, locked in `flake.lock`). It evaluates clean:

```
these 409 derivations will be built
these 1962 paths will be fetched (6.7 GiB download, 19.5 GiB unpacked)
```

The 409 local builds are almost entirely `/etc` config files and activation
scripts — trivial, not compilation. Nothing heavy builds from source.

Every package that was a guess resolved, and several match your Arch versions
exactly: hyprland 0.56.2, walker 2.17.0, elephant 2.22.0, localsend 1.17.0,
spotify 1.2.92.147, zoom 7.1.5, nsxiv 34, adwaita-fonts 50.0.

Re-run the check yourself any time after editing:

```sh
nix build --dry-run .#nixosConfigurations.aaron-laptop.config.system.build.toplevel
```
