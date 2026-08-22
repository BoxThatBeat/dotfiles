{ pkgs, ... }:

{
  # fstrim.timer was enabled on Arch (NVMe SSD).
  services.fstrim.enable = true;

  # systemd-timesyncd.service was enabled and active.
  services.timesyncd.enable = true;

  # xdg-user-dirs.service was enabled as a user unit.
  environment.systemPackages = [ pkgs.xdg-user-dirs ];

  # p11-kit-server.socket was enabled on Arch as a dependency of gnome-keyring;
  # NixOS wires that up through services.gnome.gnome-keyring (see desktop.nix).

  # Journals were unbounded on Arch. Cap them — this is a 238G laptop disk.
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1month
  '';

  # Steam (explicitly installed on Arch, with multilib enabled in pacman.conf).
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = false;
  };

  # `ssh-agent.socket` was an enabled user unit; see programs.ssh.startAgent
  # in users.nix. The sshd *server* was NOT enabled on Arch, so it stays off.
  services.openssh.enable = false;

  # Arch ran dbus-broker rather than dbus-daemon.
  services.dbus.implementation = "broker";

  programs.nix-ld.enable = true; # lets Mason/npm/pip prebuilt binaries run — see MIGRATION.md
}
