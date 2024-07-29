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
      interfaceName = "tailscale0";

      permitCertUid = "caddy";

      authKeyFile = config.age.secrets.tailscale.path;
      extraUpFlags = [ "--ssh --advertise-tags" ];
      extraDaemonFlags = [ "--outbound-http-proxy-listen=127.0.0.1:443" ];
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