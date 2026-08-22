{ pkgs, ... }:

{
  # Arch: docker.service enabled + running, user in the `docker` group.
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
    # rootless.enable = true;  # consider it; changes your socket path
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ];

  # base/apps/qemu.lua exists in your hypr config (window rules for a `qemu`
  # class), so you at least occasionally run VMs. Uncomment to enable libvirt:
  # virtualisation.libvirtd.enable = true;
  # programs.virt-manager.enable = true;
  # users.users.boxthatbeat.extraGroups = [ "libvirtd" ];
}
