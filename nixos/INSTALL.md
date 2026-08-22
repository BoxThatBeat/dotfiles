# Installing this config from a NixOS USB

Written to be read **on the installer**, where you won't have anything else.
Once the repo is pushed you can pull it up mid-install with:

```sh
curl -sL https://raw.githubusercontent.com/BoxThatBeat/dotfiles/master/nixos/INSTALL.md | less
```

## Facts about this machine that shape the process

- **One disk.** A single 238 GB NVMe holding Arch. Installing NixOS destroys it.
- **124 GB of data in `/home`, 66 GB free.** You cannot back up to this disk.
  You need an external drive of at least 128 GB.
- **No Ethernet port.** Wifi only, so the installer needs wifi (or a USB tether).
- **The ESP is being grown from 1 GB to 2 GB.** It is already 50% full under
  Arch with two kernels; NixOS keeps every generation bootable, so 1 GB is tight.

---

# Phase 0 — before you touch the disk

Do all of this from the running Arch system. It is the whole difference between
a boring install and being stranded with no working computer.

## 0.1 Push the config

The installer clones from GitHub. If it isn't pushed, it doesn't exist.

```sh
cd ~/dotfiles
git add -A
git commit -m "NixOS configuration"
git push
```

The repo is public, so the installer can clone it anonymously over HTTPS — no
SSH key needed.

## 0.2 Prove the config actually builds — do not skip this

This config was written offline, so some package attribute names are educated
guesses. Find out now, on a machine that still works, rather than at a root
prompt with no OS installed.

```sh
sudo pacman -S nix
sudo systemctl enable --now nix-daemon

# The Arch package's tmpfiles rules create /nix/var but NOT the store itself,
# so this one-time init is required or you get:
#   error: opening file "/nix/store": No such file or directory
sudo nix-store --init

mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

cd ~/dotfiles/nixos
nix build --dry-run .#nixosConfigurations.aaron-laptop.config.system.build.toplevel
```

There is no `nix-users` group on nix 2.35; the daemon socket is world-writable,
so no group membership is needed. `nix doctor` reporting `Trusted: 0` is fine
for a dry run — it only means custom substituters are skipped. Add yourself to
`trusted-users` in `/etc/nix/nix.conf` if you later do a full build.

`--dry-run` evaluates everything but downloads nothing. This has already been
run and the config evaluates clean, ending in:

```
these 409 derivations will be built
these 1962 paths will be fetched (6.7 GiB download, 19.5 GiB unpacked)
```

Re-run it after any edit you make. If you want total certainty, drop
`--dry-run` and let it build the real closure — 6.7 GiB of downloads, but the
409 local builds are trivial `/etc` files rather than compilation, so it is not
an overnight job even on this i5.

## 0.3 Write down your wifi password

You will need to type it into the installer by hand. If you don't remember it,
it's in `/var/lib/iwd/*.psk` (needs root).

## 0.4 Back up

`/home` is 124 GB, but most of it is not worth copying:

- **`~/.local/share/Trash` — 13 GB.** Empty it first and skip the copy entirely.
- **`~/.local/share/Steam` — 6.7 GB.** Redownloadable.
- **`~/.local/share/nvim` — 485 MB.** Pure cache: `mason` (which you are
  replacing with nixpkgs LSPs anyway), `lazy` (restores exactly from the
  tracked `lazy-lock.json`), and treesitter parsers (rebuilt on demand).
- **`~/Videos` — 44 GB.** Your call.

That gets you to roughly 60 GB. What actually matters:

```sh
# Empty the trash first — 13 GB you would otherwise copy
rm -rf ~/.local/share/Trash/*

sudo mount /dev/sdX1 /mnt/backup
rsync -aAXv --info=progress2 \
  --exclude '.local/share/Steam' \
  --exclude '.local/share/nvim' \
  --exclude '.local/share/Trash' \
  --exclude '.cache' \
  /home/boxthatbeat/ /mnt/backup/boxthatbeat/
```

Drop `--exclude '.local/share/Steam'` if you would rather not redownload your
library. Note there is no exclude for `.local/state` — that one you want.

`~/.ssh`, `~/.gnupg`, `~/git`, `~/Documents`, `~/Images/wallpapers`, your
Obsidian vault, `~/.local/share/task`, and — easy to miss —
**`~/.local/state/nvim`** (488 KB). That is where Neovim 0.9+ keeps undo
history, persistence.nvim sessions, and shada (marks, registers, jumplist,
per-file cursor positions). None of it regenerates, unlike everything in
`~/.local/share/nvim`.

Verify the backup **before** you wipe:

```sh
diff -rq --no-dereference ~/.ssh /mnt/backup/boxthatbeat/.ssh && echo "ssh OK"
du -sh /mnt/backup/boxthatbeat
sudo umount /mnt/backup
```

---

# Phase 1 — boot the USB

Reboot, hit **F9** (HP's boot menu) and pick the USB.

You may need to disable Secure Boot in the BIOS (**F10**) — this config does not
set up Secure Boot.

You land at a shell as user `nixos`. Everything below needs root:

```sh
sudo -i
```

## 1.1 Get online

Try these in order; the first one that exists on your ISO wins.

```sh
# a) NetworkManager, if present
nmtui

# b) iwd, same tool you use on Arch
iwctl
   station wlan0 scan
   station wlan0 get-networks
   station wlan0 connect "YOUR-SSID"
   exit

# c) wpa_supplicant — always present on the minimal ISO
wpa_passphrase "YOUR-SSID" "YOUR-PASSWORD" > /etc/wpa_supplicant.conf
systemctl restart wpa_supplicant
```

**Easiest fallback:** plug in an Android phone over USB and turn on USB
tethering. It appears as a wired NIC and needs no configuration at all.

Confirm:

```sh
ping -c3 nixos.org
```

---

# Phase 2 — partition and format

**This destroys Arch. Your backup is done and verified, right?**

```sh
wipefs -a /dev/nvme0n1

parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 2GiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart root ext4 2GiB 100%
```

The labels below are not cosmetic — `hardware-configuration.nix` matches on
them, so they must be exactly `BOOT` and `nixos`:

```sh
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/nvme0n1p2
```

Mount:

```sh
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/BOOT /mnt/boot

lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT   # sanity check
```

No swap partition is created — swap is zram, configured in `modules/nixos/boot.nix`.

---

# Phase 3 — install

## 3.1 Clone the config to its final home

```sh
mkdir -p /mnt/home/boxthatbeat
git clone https://github.com/BoxThatBeat/dotfiles.git /mnt/home/boxthatbeat/dotfiles
```

## 3.2 Cross-check the hardware detection

```sh
nixos-generate-config --root /mnt --no-filesystems
diff /mnt/etc/nixos/hardware-configuration.nix \
     /mnt/home/boxthatbeat/dotfiles/nixos/hosts/aaron-laptop/hardware-configuration.nix
```

Ignore differences in `fileSystems` (ours uses labels on purpose). If the
generator lists kernel modules in `boot.initrd.availableKernelModules` that ours
doesn't have, **add them to ours** — the generator saw your real hardware.

## 3.3 Set the stateVersion

Check what release the ISO is:

```sh
nixos-version
```

Then set `system.stateVersion` in
`/mnt/home/boxthatbeat/dotfiles/nixos/hosts/aaron-laptop/default.nix` to that
release (e.g. `"26.05"`), and the matching `home.stateVersion` in
`nixos/modules/home/default.nix`. Set it once; never change it afterwards.

```sh
nano /mnt/home/boxthatbeat/dotfiles/nixos/hosts/aaron-laptop/default.nix
nano /mnt/home/boxthatbeat/dotfiles/nixos/modules/home/default.nix
```

## 3.4 Install

```sh
nixos-install --flake /mnt/home/boxthatbeat/dotfiles/nixos#aaron-laptop
```

This downloads a few GB and takes a while. At the end it prompts for a **root
password** — set one you'll remember; you need it in Phase 4.

If it fails partway, you can fix and re-run — nothing is lost, and `/mnt` stays
mounted.

## 3.5 Hand the repo to your user

The clone is currently owned by root:

```sh
nixos-enter --root /mnt -c 'chown -R boxthatbeat:users /home/boxthatbeat'
```

---

# Phase 4 — first boot

```sh
reboot
```

Pull out the USB. You should land at SDDM.

You have no user password yet, so switch to a TTY with **Ctrl+Alt+F2**, log in
as `root`, and:

```sh
passwd boxthatbeat
```

Then **Ctrl+Alt+F1** back to SDDM and log in.

## 4.1 Put your dotfiles in place

```sh
cd ~/dotfiles
stow alacritty bat btop hypr nvim tmux waybar walker elephant task pomo keyboard-drums zsh
```

Log out and back in so Hyprland picks up the config.

## 4.2 Check the things most likely to be wrong

```sh
hyprctl version                       # must be >= 0.55 or your Lua config is ignored
notify-send "test" "mako works"       # notification daemon
vainfo | grep -i profile | head       # hardware video decode
iwctl station wlan0 show              # wifi
nvim +checkhealth                     # LSPs on PATH, no Mason breakage
systemctl --user status battery-notify 2>/dev/null || pgrep -af battery-notify
```

Your launcher is the most likely casualty — see MIGRATION.md §4b. If walker
opens empty, `fuzzel` is already installed as a working stand-in.

## 4.3 Restore your data

```sh
sudo mount /dev/sdX1 /mnt
rsync -aAXv --info=progress2 /mnt/boxthatbeat/ /home/boxthatbeat/
```

Skip `.zshrc`, `.p10k.zsh`, and `.config/*` for anything stow now owns — restore
data (`~/git`, `~/Documents`, `~/Images`, `~/.ssh`, `~/.gnupg`,
`~/.local/state/nvim`, `~/.local/share/task`) rather than config.

---

# If it goes wrong

**The install fails.** You're still in the installer with `/mnt` mounted. Fix
the config, `git commit` locally in `/mnt/home/boxthatbeat/dotfiles`, re-run
`nixos-install`. Nothing is lost.

**It boots but the desktop is broken.** Pick an older generation at the boot
menu — after a fresh install there is only one, so instead switch to a TTY
(Ctrl+Alt+F2), log in, edit the config, and:

```sh
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#aaron-laptop
```

**It doesn't boot at all.** Boot the USB again, mount as in Phase 2, and:

```sh
nixos-enter --root /mnt
```

You're now inside the installed system and can rebuild from there.

**You need Arch back.** That's what the backup is for. Nothing about this
process is recoverable without it.
