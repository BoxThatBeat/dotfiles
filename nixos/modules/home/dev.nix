{ pkgs, ... }:

{
  ###########################################################################
  # Development toolchains.
  #
  # Two Arch habits need rethinking on NixOS and are called out inline:
  #   1. `rustup` — works, but see the note below.
  #   2. `nvm`    — works only because of programs.nix-ld; prefer devshells.
  ###########################################################################

  home.packages = with pkgs; [
    ##### C / C++ / embedded ################################################
    gcc
    gnumake
    cmake
    pkg-config
    gdb
    gcc-arm-embedded    # Arch: arm-none-eabi-gcc
    openocd
    stlink
    dfu-util            # for the STM32 DFU flashing your udev rules imply

    ##### Rust ##############################################################
    # You use rustup on Arch. It works on NixOS *because* nix-ld is enabled
    # (rustup ships dynamically-linked binaries expecting an FHS layout).
    # The idiomatic alternative is per-project rust via a devshell + the
    # `rust-overlay` or `fenix` flake. Keeping rustup for now = zero friction.
    rustup

    ##### Node ##############################################################
    # Your zshrc sources nvm from ~/.config/nvm and you're on node v24.
    # nvm-installed node needs nix-ld to run. Prefer this system node and use
    # devshells per project; keep nvm only for projects that pin odd versions.
    nodejs_24
    nodePackages.npm
    pnpm

    ##### Python ############################################################
    # Arch had: python, python-virtualenv, python311 (AUR), and you keep venvs
    # in ~/.venv/bugwarrior and ~/git/algonquin-grading-tui/.venv.
    # IMPORTANT: pip-installed wheels with native extensions will not run
    # without nix-ld. See MIGRATION.md.
    python313
    python313Packages.virtualenv
    python313Packages.pip
    uv                  # much better story than raw venv on NixOS

    ##### Go ################################################################
    go
    gopls

    ##### Neovim / LazyVim support #########################################
    # CRITICAL: Mason downloads prebuilt binaries that assume an FHS layout and
    # generally will NOT run on NixOS. Everything you currently have installed
    # via Mason is listed below, sourced from nixpkgs instead. After switching,
    # disable Mason's auto-install (see MIGRATION.md) and these take over.
    lua-language-server           # mason: lua-language-server
    bash-language-server          # mason: bash-language-server
    vscode-langservers-extracted  # mason: json-lsp (+ html/css/eslint)
    marksman                      # mason: marksman
    markdownlint-cli2             # mason: markdownlint-cli2
    nodePackages.prettier         # mason: prettier
    shellcheck                    # mason: shellcheck
    shfmt                         # mason: shfmt
    stylua                        # mason: stylua
    tailwindcss-language-server   # mason: tailwindcss-language-server
    vtsls                         # mason: vtsls
    tree-sitter                   # mason: tree-sitter-cli
    vscode-js-debug               # mason: js-debug-adapter
    nixd                          # new: LSP for the .nix files you now maintain
    nixfmt-rfc-style

    ##### Misc dev ##########################################################
    gh
    direnv                        # pairs with devshells; see programs.direnv below
    just
  ];

  # direnv + nix-direnv is the single biggest quality-of-life win moving from
  # Arch to NixOS: per-project toolchains that activate on `cd`.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
