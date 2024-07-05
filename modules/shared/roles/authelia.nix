{ config, pkgs, lib, ... }:
with lib;
let cfg = config.roles.authelia;
in
{
  options.roles.authelia = with types; {
    enable = mkEnableOption "Enable Authelia";
  };

  config = mkIf cfg.enable {
    # Enable Authelia
    virtualisation.oci-containers.containers = {
      authelia = {
        image = "authelia/authelia:latest";
        ports = [ "9091:9091" ];
        volumes = [ "/storage/docker/authelia:/config" ];
      };
    };
  };
}