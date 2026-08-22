{
  description = "aaron-laptop — NixOS config migrated from Arch (HP ENVY x360 15-bp0xx)";

  inputs = {
    # Rolling channel, closest in spirit to Arch. Swap to nixos-25.11 for stable.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Walker (your launcher) ships both `walker` and its `elephant` backend
    # from its own flake. nixpkgs packages walker alone, which is not enough
    # for walker 2.x. Uncomment this and the two lines in
    # modules/nixos/desktop.nix to get a working launcher with your existing
    # ~/.config/walker and ~/.config/elephant untouched.
    # walker.url = "github:abenz1267/walker";

    # OPTIONAL but recommended: the upstream Hyprland flake tracks releases far
    # faster than nixpkgs. Your hypr config is Lua-based, which requires
    # Hyprland >= 0.55. If nixpkgs lags behind that, uncomment this input and
    # follow the note in modules/nixos/desktop.nix.
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
