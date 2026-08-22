{ ... }:

{
  # Ported from ~/.gitconfig
  programs.git = {
    enable = true;
    userName = "Aaron Buitenwerf";
    userEmail = "buitenwerfa@gmail.com";
    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase = false;
      # Nice-to-haves that were not on the Arch box; delete if you want parity.
      diff.colorMoved = "default";
      push.autoSetupRemote = true;
    };
  };

  programs.lazygit.enable = true;
}
