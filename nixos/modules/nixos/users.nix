{ pkgs, ... }:

{
  # Arch: boxthatbeat uid=1000, shell /usr/bin/zsh
  #   groups: boxthatbeat wheel input uucp plugdev docker
  users.users.boxthatbeat = {
    isNormalUser = true;
    uid = 1000;
    description = "Aaron Buitenwerf";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"     # sudo
      "input"     # /dev/input/event* for keyboard-drums (see udev.nix)
      "uucp"      # serial devices — arm-none-eabi / flight-controller work
      "dialout"   # NixOS' name for the serial group; keep both
      "plugdev"   # ZSA keyboard flashing (see udev.nix)
      "docker"
      "video"     # brightnessctl
      "render"
      "networkmanager"
    ];

    # Populate this from `cat ~/.ssh/*.pub` before the first boot if you want
    # SSH access to this machine without a password.
    openssh.authorizedKeys.keys = [ ];
  };

  # `plugdev` does not exist on NixOS by default — the ZSA udev rules reference it.
  users.groups.plugdev = { };

  # Required for `users.users.*.shell = pkgs.zsh` to be a valid login shell.
  programs.zsh.enable = true;

  security.sudo.wheelNeedsPassword = true;

  # Was running on Arch (polkit.service).
  security.polkit.enable = true;
  security.rtkit.enable = true; # rtkit-daemon.service — PipeWire realtime priority

  # Your zshrc leans on an SSH agent socket (the tmux/1Password symlink dance).
  programs.ssh.startAgent = true;
}
