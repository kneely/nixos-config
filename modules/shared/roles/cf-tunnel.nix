{ config, pkgs, lib, secrets, ... }:
with lib;
let cfg = config.roles.cf-tunnel;
in
{
  options.roles.cf-tunnel = with types; {
    enable = mkEnableOption "Enable Cloudflare Tunnel";
  };

  config = mkIf cfg.enable {
    # age.secrets.nginx-htpasswd = {
    #   file = ../secrets/nginx.htpasswd.age;
    #   mode = "770";
    #   owner = "nginx";
    #   group = "nginx";
    # };
    # age.secrets.cloudflare-tunnel.file = "${secrets}/cloudflare-tunnel.age";
    age.secrets.cloudflare-tunnel = {
      file = "${secrets}/cloudflare-tunnel-config.age";
      mode = "770";
      owner = "cloudflared";
      group = "cloudflared";
    };
    
    users.groups.cloudflared = { };

    users.users.cloudflared = {
      group = "cloudflared";
      isSystemUser = true;
    };

    services.cloudflared = {
      enable = true;
      group = "cloudflared";
      user = "cloudflared";
      tunnels = {
        "7e158130-fbe1-4af7-8fc9-353fb116ba2b" = {
          credentialsFile = config.age.secrets.cloudflare-tunnel.path;
          default = "http_status:404";
          ingress = {
            "chat.neelyinno.com" = {
              service = "http://localhost:3000";
            };
          };
        };
      };
    };
  };
}