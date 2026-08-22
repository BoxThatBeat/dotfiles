# Migration notes: Arch → NixOS

Everything here is something the config could *not* mechanically translate, or
where a decision was made for you. Read it before your first `nixos-install`.

---

## 1. Packages with no nixpkgs equivalent

| Arch package | Status | What to do |
|---|---|---|
| `elephant`, `elephant-desktopapplications` (AUR) | **Packaged after all** — `pkgs.elephant` 2.22.0, the same version you run, including the `desktopapplications.so` and `calc.so` providers your config uses. | Nothing to do; it's installed in `desktop.nix` alongside walker 2.17.0. |
| `ipad_charge` (AUR) | **Not in nixpkgs.** A ~200-line C program. | The udev rules are already in `modules/nixos/udev.nix` and are inert until the binary exists. Package it with a small `pkgs.stdenv.mkDerivation` pulling from `github:mkorenkov/ipad_charge`, or drop the feature. |
| `keyboard-drums` | Your own project (config lives in `dotfiles/keyboard-drums/`). | Build it from source in a devshell, or write a derivation. The `input`-group udev rule it needs is already ported. |
| `fstl` (AUR) | **Not in nixpkgs.** STL viewer. | `f3d` or `meshlab` are packaged and cover the same job; both handle STL. |
| `gsd-pi` (npm global) | Node package, install with npm as before. | Needs `programs.nix-ld` (already enabled) if it ships native binaries. |
| `snapd` | Not in nixpkgs core. | **Deliberately dropped.** Your only snaps are `core20`, `bare`, `gtk-common-themes`, `snapd`, `gnome-3-38-2004` — all runtime scaffolding, no actual applications. Nothing of yours depends on it. If you do need snap later: the `nix-snapd` flake provides `services.snap.enable`. |
| `electron36`, `electron37`, `python311`, `qt5-location`, `qt5-webchannel`, `python-pkg_resources`, `webkit2gtk-4.1` | AUR *dependencies* of other packages, not things you chose. | Nothing to do — Nix resolves these per-package automatically. |
| `yay` | AUR helper. | No equivalent needed; `nix flake update` replaces it. |
| `sxiv` | Unmaintained upstream. | Mapped to `nsxiv`, the maintained fork. Same keybinds. |
| `ex-vi-compat`, `xorg-xinit`, `wpa_supplicant`, `wireless_tools` | Vestigial on your box (you use iwd, not wpa_supplicant; Wayland, not xinit). | **Dropped.** `iw` replaces `wireless_tools`. Re-add if something surprises you. |

---

## 2. Neovim + Mason — this will break if you ignore it

You have 14 tools installed through Mason (`lua-language-server`, `vtsls`,
`prettier`, `shellcheck`, `stylua`, `marksman`, `js-debug-adapter`, …). Mason
downloads **prebuilt, dynamically-linked binaries** that expect an FHS
filesystem. On NixOS most of them fail with `no such file or directory` even
though the file is right there — the ELF interpreter path doesn't exist.

Two mitigations are already in place:

1. Every one of those 14 tools is installed from nixpkgs in
   `modules/home/dev.nix`, so they're on `$PATH` before nvim starts.
2. `programs.nix-ld.enable = true` in `modules/nixos/services.nix` provides a
   fake FHS interpreter, which rescues *most* Mason binaries anyway.

You should still stop Mason from managing them. In your LazyVim config add:

```lua
-- dotfiles/nvim/.config/nvim/lua/plugins/mason.lua
return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
}
```

`nvim-treesitter` compiles parsers locally with `gcc`, which is in `dev.nix` —
that part keeps working unchanged.

---

## 3. Toolchains that assume FHS

- **rustup** — kept, and works thanks to `nix-ld`. The idiomatic alternative is
  a `rust-overlay` devshell per project. Your `~/.cargo/bin` is currently empty,
  so nothing is at risk either way.
- **nvm** (`~/.config/nvm`, node v24) — your `.zshrc` sources it. It will keep
  working under `nix-ld`, but `nodejs_24` is now installed system-wide and
  `direnv` + `nix-direnv` (in `dev.nix`) is the better path. Leave the nvm block
  in `.zshrc`; it no-ops harmlessly if `~/.config/nvm` doesn't exist.
- **Python venvs** — `~/.venv/bugwarrior` and
  `~/git/algonquin-grading-tui/.venv` contain pip wheels with native extensions.
  Recreate them after switching (`uv venv` is faster and handles this better).
  Your `bugwarrior*` aliases point at `~/.venv/bugwarrior/bin/`, so they'll work
  once the venv is rebuilt.

---

## 4. Dotfile bugs — fixed

These were found by reading the configs and have already been fixed in the repo
(and therefore on the Arch install too, since those files are stow symlinks):

- **`task/.config/task/taskrc`** had a dead `data.location=/home/developer/.task`
  that was silently overridden by `data.location=~/.local/share/task` four lines
  later. The dead line is gone. `TASKRC` is now set only by `.zshrc`; the Nix
  config no longer declares taskwarrior or `TASKRC`.
- **`zsh/.zshrc`** had `export PATH=/home/developer/.opencode/bin:$PATH` — a
  stale container path. Removed.
- **`hyprpaper` started twice**, from `base/autostart.lua` and `autostart.lua`.
  It now starts once, from `base/autostart.lua`, alongside the other session
  daemons (waybar, elephant, walker, swayosd). Your personal `autostart.lua`
  keeps only `battery-notify.sh`.
- **`QT_STYLE_OVERRIDE=kvantum`** in `base/envs.lua` pointed at a theme engine
  that was never installed, so Qt apps silently fell back. Removed.
- **`battery-notify.sh`** existed only in `~/.config/hypr/scripts/` and was not
  tracked. It is now in the repo at `hypr/.config/hypr/scripts/`, and the live
  Arch copy is a symlink to it like every other stowed file. It survives the
  move to NixOS unchanged; `libnotify` provides `notify-send`.
- **mako vs dunst** — both were installed. `mako` is the one that actually runs
  (PID 1413, owner of `org.freedesktop.Notifications`, started by
  `mako.service`); dunst had never run and was referenced nowhere. The Nix
  config installs mako only, with D-Bus activation wired up the same way Arch
  had it. Remove dunst from Arch with `sudo pacman -Rns dunst`.

## 4a. Still outstanding

- **`~/.config/hypr/hyprland.conf`** is left over from before the Lua migration
  and exists only on the live Arch box, not in the repo. Hyprland >= 0.55
  prefers `hyprland.lua`, so it is dead weight, but delete it to be sure:
  `rm ~/.config/hypr/hyprland.conf`.
- **`~/.XCompose` does not exist**, though `base/envs.lua` sets `XCOMPOSEFILE`
  to it and `base/input.lua` binds Caps Lock as Compose. Compose still works
  off the system defaults; add and stow a `.XCompose` only if you want custom
  sequences.

---

## 4b. Launcher

Resolved — no action needed. A dry build against the pinned nixpkgs gives
`walker` 2.17.0 and `elephant` 2.22.0, both identical to your Arch versions, and
the elephant package ships the full provider set (`desktopapplications.so`,
`calc.so`, `bitwarden.so`, `clipboard.so`, `playerctl.so`, and others). Your
`~/.config/walker` and `~/.config/elephant` carry over untouched.

`fuzzel` is also installed as a spare, but nothing autostarts it.

## 5. Deliberate additions (not present on Arch)

These are improvements, not ports. Remove them if you want strict parity.

- `services.tlp` + `services.thermald` — meaningful battery and thermal wins on
  a 2017 Kaby Lake laptop that currently runs with no power management at all.
- `nix.gc` weekly, 30-day retention — the store grows without this.
- `services.journald` capped at 500 M — yours was unbounded.
- `boot.loader.systemd-boot.configurationLimit = 10` — your ESP is only 1 GiB,
  and each generation's kernel+initrd is ~120 MiB. Without this cap you will
  fill it in roughly eight rebuilds. **This is the single most likely thing to
  bite you.** Consider resizing the ESP to 2 GiB if you repartition anyway.
- `programs.direnv` + `nix-direnv`.
- `networking.firewall` enabled with LocalSend's port 53317 opened — Arch had
  no firewall running at all.
- `nixd` + `nixfmt-rfc-style` — LSP for the config you now maintain.

---

## 6. Deliberate omissions

- **`seatd`** — was enabled on Arch. NixOS's `programs.hyprland` uses
  systemd-logind for seat management; running seatd alongside is redundant and
  can conflict. Left off, with a commented `services.seatd.enable` in
  `desktop.nix` if you hit seat errors.
- **`sshd`** — you had the `ssh-agent.socket` *client* unit enabled but no
  server. `services.openssh.enable = false` preserves that. Flip it on plus fill
  in `openssh.authorizedKeys.keys` in `users.nix` if you want to reach this
  laptop remotely.
- **`linux-lts`** — you had it installed as a fallback but booted mainline. Add
  `boot.kernelPackages = pkgs.linuxPackages` (the NixOS LTS default) to
  `boot.nix` if you want the safety net back; NixOS generations already give you
  a rollback path, which is what the LTS kernel was doing for you.

---

## 7. Hyprland version — verified

Your `~/.config/hypr` uses the Lua format (`hyprland.lua`, `base/*.lua`), which
requires Hyprland >= 0.55. The pinned nixpkgs gives **0.56.2**, exactly what you
run on Arch, so the config loads as-is and no extra flake input is needed.

Worth re-checking after a big `nix flake update`, because the failure mode is
silent: too-old Hyprland ignores the Lua files and starts with defaults, which
looks like your config vanished rather than like a version error.

```sh
nix eval --raw .#nixosConfigurations.aaron-laptop.pkgs.hyprland.version
```
