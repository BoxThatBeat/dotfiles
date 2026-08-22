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
- **The ESP is 1 GB and already 50% full** under Arch with two kernels. NixOS
  keeps every generation bootable, so this needs managing either way.

## Two paths — pick one before you start

**Path A — dual-boot (recommended).** Shrink Arch, install NixOS alongside it,
keep both in the boot menu. Run NixOS for a week; if something is broken you
reboot into a working Arch instead of losing the machine. Reclaim the Arch
partition when you are happy. Phase 2A below.

**Path B — full wipe.** Simpler and gives NixOS the whole disk immediately, but
if the desktop does not come up you have no working system until you fix it or
restore from backup. Phase 2B below.

Path A is the recommendation. The dry run proved every package resolves and
every option is valid — but nothing about it proves SDDM starts Hyprland, that
iwd associates, that audio routes, or that walker and elephant talk to each
other. Those only get tested by booting. Expect at least one thing to need
fixing on the first boot; that is normal, and Path A makes it a minor evening
rather than a crisis.

Everything in Phase 0 and Phase 1 applies to both paths. **Both paths need the
backup** — Path A reduces downtime risk, not data-loss risk, and the filesystem
shrink is the single most dangerous step in this document.

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

## 0.4 Free up the ESP (Path A only)

Dual-booting means Arch and NixOS share the 1 GB ESP. You boot mainline `linux`,
not `linux-lts`, and the LTS kernel plus its fallback initramfs is eating 246 MB
of it. Removing it leaves ~760 MB — plenty for Arch's entries plus a few NixOS
generations.

```sh
sudo pacman -Rns linux-lts
sudo bootctl update
df -h /boot          # expect ~261M used
```

Reboot once afterwards to confirm Arch still starts from the mainline kernel
before you go any further.

## 0.5 Back up

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

# Phase 2A — dual-boot: shrink Arch, add a NixOS partition

Skip to Phase 2B if you chose the full wipe.

Current layout:

```
nvme0n1     238.5G
├─nvme0n1p1     1G  vfat  ->  /boot   (shared with NixOS, do NOT reformat)
└─nvme0n1p2 237.5G  ext4  ->  /       (Arch, to be shrunk)
```

Target:

```
nvme0n1     238.5G
├─nvme0n1p1     1G  vfat   label BOOT   ->  /boot   (shared)
├─nvme0n1p2   130G  ext4                ->  Arch /
└─nvme0n1p3   107G  ext4   label nixos  ->  NixOS /
```

## 2A.1 Label the shared ESP — non-destructive

The config matches `/boot` by the label `BOOT`. Setting it does **not** reformat
and does not disturb Arch, whose fstab uses UUIDs:

```sh
fatlabel /dev/nvme0n1p1 BOOT
lsblk -o NAME,FSTYPE,LABEL /dev/nvme0n1     # confirm BOOT appears
```

**Never run `mkfs` on nvme0n1p1 in this path.** That erases Arch's bootloader.

## 2A.2 Shrink the Arch filesystem

This is the most dangerous step in this document. The filesystem must be
unmounted, and the order matters: shrink the *filesystem* first, then the
*partition*. Reversing that truncates your data.

```sh
umount /dev/nvme0n1p2 2>/dev/null   # make sure it is not mounted

e2fsck -f /dev/nvme0n1p2            # mandatory; resize2fs refuses without it
resize2fs /dev/nvme0n1p2 130G       # filesystem first
```

`resize2fs` fails if 130G is smaller than the data in use — that is the safety
net working, not an error to force past. If it complains, go back and free more
space (Trash, `~/Videos`, Steam) before retrying.

Now shrink the partition to match. Give it slightly more than the filesystem
(132G vs 130G) so a rounding difference can never cut into data:

```sh
parted /dev/nvme0n1 -- resizepart 2 132GB
```

Answer yes to the warning. Then verify, and only proceed if this is clean:

```sh
e2fsck -f /dev/nvme0n1p2
```

## 2A.3 Create the NixOS partition

```sh
parted /dev/nvme0n1 -- mkpart nixos ext4 132GB 100%
mkfs.ext4 -L nixos /dev/nvme0n1p3
```

The label must be exactly `nixos` — `hardware-configuration.nix` matches on it.

## 2A.4 Mount

```sh
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/BOOT /mnt/boot

lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT
ls /mnt/boot/loader/entries/        # Arch's entries must still be here
```

If that last command is empty, stop — you have reformatted the shared ESP and
Arch will not boot.

## 2A.5 Lower the generation limit for the trial

While sharing a 1 GB ESP, keep NixOS's footprint small. In
`hosts/aaron-laptop/default.nix` add:

```nix
boot.loader.systemd-boot.configurationLimit = 3;
```

Raise it back to 10 (the default in `modules/nixos/boot.nix`) once Arch is gone.

Continue to Phase 3.

---

# Phase 2B — full wipe

**This destroys Arch. Your backup is done and verified, right?**

```sh
wipefs -a /dev/nvme0n1

parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 2GiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart root ext4 2GiB 100%
```

The ESP grows to 2 GB here because nothing else needs the space and it removes
the generation-limit constraint entirely.

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

No swap partition is created in either path — swap is zram, configured in
`modules/nixos/boot.nix`.

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

Pull out the USB.

**Dual-boot:** systemd-boot now lists both systems. NixOS generations appear as
`NixOS - Default`, and Arch's entries are still there under `Arch Linux (linux)`.
NixOS becomes the default; press a key during the 3-second timeout to pick Arch.
If Arch is missing from the menu, you reformatted the shared ESP — stop and see
"If it goes wrong".

You should land at SDDM.

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

**Dual-boot:** your Arch home is still on the disk, so copy straight from it —
no external drive needed, and much faster:

```sh
sudo mkdir -p /mnt/arch
sudo mount /dev/nvme0n1p2 /mnt/arch
rsync -aAXv --info=progress2 \
  --exclude '.local/share/Steam' \
  --exclude '.local/share/nvim' \
  --exclude '.local/share/Trash' \
  --exclude '.cache' \
  /mnt/arch/home/boxthatbeat/ /home/boxthatbeat/
```

Consider copying rather than moving at first — leaving Arch's home intact is the
whole point of the trial.

**Full wipe:** from the external backup instead:

```sh
sudo mount /dev/sdX1 /mnt
rsync -aAXv --info=progress2 /mnt/boxthatbeat/ /home/boxthatbeat/
```

Skip `.zshrc`, `.p10k.zsh`, and `.config/*` for anything stow now owns — restore
data (`~/git`, `~/Documents`, `~/Images`, `~/.ssh`, `~/.gnupg`,
`~/.local/state/nvim`, `~/.local/share/task`) rather than config.

---

# Phase 5 — reclaiming the Arch partition (dual-boot only)

Do this only after NixOS has handled everything you actually do for a week or
two: a full workday, a video call, a game, an SSH session, printing if you
print, an external monitor if you use one. There is no hurry — 107 GB is enough
to live on.

When you are ready:

```sh
# 1. Anything left on the Arch side that you still want
sudo mount /dev/nvme0n1p2 /mnt/arch
# ...copy it out...
sudo umount /mnt/arch

# 2. Drop Arch's boot entries
sudo rm /boot/loader/entries/*arch*.conf
sudo rm -f /boot/vmlinuz-linux /boot/initramfs-linux*.img /boot/intel-ucode.img

# 3. Delete the partition and grow NixOS into the space
sudo parted /dev/nvme0n1 -- rm 2
sudo parted /dev/nvme0n1 -- resizepart 3 100%
sudo resize2fs /dev/nvme0n1p3
```

`resize2fs` grows a mounted ext4 filesystem online, so no USB boot is needed for
step 3 — unlike shrinking.

Then raise the generation limit back up, since the ESP is no longer contested.
Remove the `configurationLimit = 3` line you added in Phase 2A.5 so the default
of 10 from `modules/nixos/boot.nix` applies, and rebuild:

```sh
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#aaron-laptop
```

Note the ESP stays 1 GB in this path. With `configurationLimit = 10` and ~100 MB
per generation that is fine, but it is the one thing the full-wipe path would
have given you more room on.

---

# If it goes wrong

**The install fails.** You're still in the installer with `/mnt` mounted. Fix
the config, `git commit` locally in `/mnt/home/boxthatbeat/dotfiles`, re-run
`nixos-install`. Nothing is lost.

**It boots but the desktop is broken.** *Dual-boot: reboot and pick Arch.* You
have a working machine again, and you can fix the NixOS config from there at
your own pace — the partition is still mounted-able at `/dev/nvme0n1p3`.

Otherwise, pick an older generation at the boot menu — after a fresh install
there is only one, so instead switch to a TTY
(Ctrl+Alt+F2), log in, edit the config, and:

```sh
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#aaron-laptop
```

**It doesn't boot at all.** Boot the USB again, mount as in Phase 2A/2B, and:

```sh
nixos-enter --root /mnt
```

You're now inside the installed system and can rebuild from there.

**Arch is missing from the boot menu (dual-boot).** Its entries live in
`/boot/loader/entries/*.conf` and its kernels in `/boot/vmlinuz-linux*`. If the
ESP was reformatted, boot the USB and regenerate them — or reinstall the Arch
bootloader from an Arch USB with `bootctl install`. The Arch root partition
itself is untouched by anything in Phase 2A.

**You need Arch back (full wipe).** That's what the backup is for. Nothing about
this process is recoverable without it.
