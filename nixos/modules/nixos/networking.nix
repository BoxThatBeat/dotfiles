{ ... }:

{
  # You deliberately do NOT use NetworkManager. Arch had:
  #   systemd-networkd + systemd-resolved + iwd   (wpa_supplicant installed but unused)
  # This reproduces that exactly.
  networking.networkmanager.enable = false;

  networking.wireless.iwd = {
    enable = true;
    settings = {
      General.EnableNetworkConfiguration = false; # networkd does the addressing
      Network.NameResolvingService = "systemd";
      Settings.AutoConnect = true;
    };
  };

  networking.useNetworkd = true;
  systemd.network.enable = true;

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    llmnr = "true";
    settings.Resolve.MulticastDNS = "yes";
  };

  # Direct ports of /etc/systemd/network/20-{ethernet,wlan,wwan}.network.
  # The RouteMetric values come from Arch's shipped files and exist so wired
  # beats wireless beats mobile broadband.
  systemd.network.networks = {
    "20-ethernet" = {
      # Globbing the name rather than `Type=ether` avoids matching docker veth*.
      matchConfig.Name = [ "en*" "eth*" ];
      linkConfig.RequiredForOnline = "routable";
      networkConfig = {
        DHCP = "yes";
        MulticastDNS = "yes";
      };
      dhcpV4Config.RouteMetric = 100;
      ipv6AcceptRAConfig.RouteMetric = 100;
    };

    "20-wlan" = {
      matchConfig.Name = "wl*";
      linkConfig.RequiredForOnline = "routable";
      networkConfig = {
        DHCP = "yes";
        MulticastDNS = "yes";
      };
      dhcpV4Config.RouteMetric = 600;
      ipv6AcceptRAConfig.RouteMetric = 600;
    };

    "20-wwan" = {
      matchConfig.Name = "ww*";
      linkConfig.RequiredForOnline = "routable";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 700;
      ipv6AcceptRAConfig.RouteMetric = 700;
    };
  };

  # A laptop that boots on wifi should not block for ~90s waiting for a link.
  # `RequiredForOnline=routable` above is per-interface; this makes ONE routable
  # interface sufficient for network-online.target.
  systemd.network.wait-online = {
    anyInterface = true;
    timeout = 10;
  };

  networking.firewall = {
    enable = true;
    # LocalSend needs these to discover and receive from phones on the LAN.
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
}
