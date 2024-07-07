{ config, pkgs, lib, secrets, ... }:
with lib;
let cfg = config.roles.tailscale;
in
{
  options.roles.tailscale = with types; {
    enable = mkEnableOption "Enable Tailscale daemon";
  };

  config = mkIf cfg.enable {
    # Enable tailscale daemon.
    services.tailscale = {
      enable = true;
      interfaceName = catalog.tailscale.interface;

      authKeyFile = config.age.secrets.tailscale.path;
      extraUpFlags = [ "--ssh" ];
    };

    age.secrets.tailscale.file = "${secrets}/tailscale-auth-key.age";

    networking.firewall = {
      # Trust inbound tailnet traffic.
      trustedInterfaces = [ "tailscale0" ];

      # Allow tailscale through firewall.
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}