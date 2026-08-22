{
  description = "aaron-laptop — NixOS config migrated from Arch (HP ENVY x360 15-bp0xx)";

  inputs = {
    # Rolling channel, closest in spirit to Arch, and the only one that matches
    # the Hyprland 0.56.2 you run today. Swap the two lines below for the
    # current stable release; see "Which channel" in README.md for the tradeoff.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # nixpkgs currently carries Hyprland 0.56.2, matching the Arch install, so
    # this is not needed. Uncomment only if a future update drops nixpkgs below
    # 0.55, which is the minimum for the Lua config format.
    # hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.aaron-laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          # Hardware profiles for an Intel laptop with an SSD.
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd

          ./hosts/aaron-laptop

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.boxthatbeat = import ./modules/home;
            home-manager.backupFileExtension = "hm-bak";
          }
        ];
      };
    };
}
