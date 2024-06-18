{ pkgs, lib, config, ... }:
with lib;
let 
  cfg = config.profiles.mediaserver;
  dataDirBase = "/pool/media";
in {
  options.profiles.mediaserver.enable =
    mkEnableOption "Enable media server profile";

  config = mkIf cfg.enable {

    services = {
      nzbget = {
        enable = true;
        user = "nzbget";
        group = "media";
        setting = {
          MainDir = "${dataDirBase}/downloads/usenet";
          ControlIP=0.0.0.0;
        };
      };

      radarr = {
        enable = true;
        user = "radarr";
        group = "media";
        dataDir = "${dataDirBase}/radarr";
      };

      sonarr = {
        enable = true;
        user = "sonarr";
        group = "media";
        dataDir = "${dataDirBase}/sonarr";
      };

      transmission = {
        enable = true;
        downloadDirPermissions = "755";
        settings = {
          download-dir = "/space/incoming";
          incomplete-dir = "/var/lib/transmission/.incomplete";
          rpc-authentication-required = true;
          rpc-whitelist-enabled = false;
          rpc-host-whitelist-enabled = false;
          rpc-username = "marcus";
          umask = 0;
        };
        credentialsFile = config.age.secrets.transmission.path;
      };

      jellyfin.enable = true;
    };
  };
}